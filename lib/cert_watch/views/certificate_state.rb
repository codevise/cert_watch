require 'arbre'
require 'active_admin'

module CertWatch
  module Views
    class CertificateState < Arbre::Component
      builder_method :cert_watch_certificate_state

      STATE_MAPPING = {
        'installed' => 'ok',
        'installing' => 'warn',
        'renewing' => 'warn',
        'installing_failed' => 'error',
        'renewing_failed' => 'error'
      }.freeze

      def build(certificate_or_domain, options = {})
        state = get_state(certificate_or_domain)
        format = options.fetch(:format, 'short')

        add_class 'cert_watch_certificate_state'

        status_tag(t(state, scope: "cert_watch.states.#{format}"),
                   [state, STATE_MAPPING[state]].compact.join(' '))
      end

      private

      def get_state(certificate_or_domain)
        get_certificate(certificate_or_domain).try(:state) || 'not_found'
      end

      def get_certificate(certificate_or_domain)
        if certificate_or_domain.is_a?(String)
          Certificate.find_by_domain(certificate_or_domain)
        else
          certificate_or_domain
        end
      end
    end
  end
end
