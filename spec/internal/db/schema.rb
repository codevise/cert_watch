ActiveRecord::Schema.define do
  create_table(:test_domain_owner, force: true) do |t|
    t.string :name
    t.string :cname
    t.timestamps null: false
  end
end
