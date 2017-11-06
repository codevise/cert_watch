class AddProviderToCertificates < ActiveRecord::Migration
  def change
    add_column :cert_watch_certificates, :provider, :string, default: 'certbot', null: false
  end
end
