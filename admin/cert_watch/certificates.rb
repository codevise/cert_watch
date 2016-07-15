require 'cert_watch/views/all'

module CertWatch
  ActiveAdmin.register Certificate do
    menu priority: 100

    actions :index, :new, :create, :show

    config.batch_actions = false

    index do
      column :domain do |certificate|
        link_to(certificate.domain, admin_cert_watch_certificate_path(certificate))
      end
      column :state do |certificate|
        cert_watch_certificate_state(certificate)
      end
      column :last_renewed_at
      column :last_renewal_failed_at
      column :last_installed_at
      column :last_install_failed_at
    end

    scope :all
    scope :installed
    scope :processing
    scope :failed
    scope :abandoned

    filter :domain
    filter :last_renewed_at

    form do |f|
      f.inputs do
        f.input :domain
      end
      f.actions
    end

    action_item(only: :show) do
      if resource.can_renew?
        button_to(I18n.t('cert_watch.admin.certificates.renew'),
                  renew_admin_cert_watch_certificate_path(resource),
                  method: :post,
                  data: {
                    rel: 'renew',
                    confirm: I18n.t('cert_watch.admin.certificates.confirm_renew')
                  })
      end
    end

    action_item(only: :show) do
      if resource.can_install?
        button_to(I18n.t('cert_watch.admin.certificates.install'),
                  install_admin_cert_watch_certificate_path(resource),
                  method: :post,
                  data: {
                    rel: 'install',
                    confirm: I18n.t('cert_watch.admin.certificates.confirm_install')
                  })
      end
    end

    member_action :renew, method: :post do
      resource = Certificate.find(params[:id])
      resource.renew
      redirect_to(admin_cert_watch_certificate_path(resource))
    end

    member_action :install, method: :post do
      resource = Certificate.find(params[:id])
      resource.install
      redirect_to(admin_cert_watch_certificate_path(resource))
    end

    show title: :domain do |certificate|
      attributes_table_for(certificate) do
        row :domain
        row :state do
          cert_watch_certificate_state(certificate)
        end
        row :created_at
        row :last_renewed_at
        row :last_renewal_failed_at
        row :last_installed_at
        row :last_install_failed_at
      end
    end

    controller do
      def permitted_params
        params.permit(cert_watch_certificate: [:domain])
      end
    end
  end
end
