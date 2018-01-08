module CertWatch
  class Certificate < ActiveRecord::Base
    PROVIDERS = %w(certbot custom).freeze

    validates :provider, inclusion: PROVIDERS

    state_machine initial: 'not_installed' do
      extend StateMachineJob::Macro

      event :renew do
        transition 'not_installed' => 'renewing'
        transition 'installed' => 'renewing'
        transition 'renewing_failed' => 'renewing'
        transition 'installing_failed' => 'renewing'
        transition 'abandoned' => 'renewing'
      end

      event :install do
        transition 'not_installed' => 'installing'
        transition 'installed' => 'installing'
        transition 'installing_failed' => 'installing'
      end

      job RenewCertificateJob do
        on_enter 'renewing'
        result ok: 'installing'
        result error: 'renewing_failed'
      end

      job InstallCertificateJob do
        on_enter 'installing'
        result ok: 'installed'
        result error: 'installing_failed'
      end

      event :abandon do
        transition any => 'abandoned'
      end
    end

    scope(:installed, -> { where(state: 'installed') })
    scope(:processing, -> { where(state: %w(renewing installing)) })
    scope(:failed, -> { where(state: %w(renewing_failed installing_failed)) })
    scope(:expiring, -> { where('last_renewed_at < ?', CertWatch.config.renewal_interval.ago) })
    scope(:abandoned, -> { where(state: 'abandoned') })

    scope(:auto_renewable, -> { where.not(provider: 'custom') })
    scope(:custom, -> { where(provider: 'custom') })

    def can_renew?
      auto_renewable? && super
    end

    def can_install?
      complete? && super
    end

    def auto_renewable?
      !custom?
    end

    def custom?
      provider == 'custom'
    end

    def complete?
      public_key.present? &&
        private_key.present? &&
        chain.present?
    end
  end
end
