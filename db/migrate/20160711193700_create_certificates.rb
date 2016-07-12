class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :cert_watch_certificates do |t|
      t.string :state, default: 'not_installed', null: false
      t.string :domain

      t.datetime :last_renewed_at
      t.datetime :last_renewal_failed_at

      t.datetime :last_installed_at
      t.datetime :last_install_failed_at

      t.timestamps null: false
    end

    add_index 'cert_watch_certificates', ['domain'], name: 'index_cert_watch_certificates_on_domain', using: :btree
  end
end
