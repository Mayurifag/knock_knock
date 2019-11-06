class AddSqliteSchemas < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email, unique: true, null: false
      t.string :password_digest, null: false

      t.timestamps null: false
    end

    create_table :admins do |t|
      t.string :email
      t.string :password_digest

      t.timestamps null: false
    end

    create_table :vendors do |t|
      t.string :email
      t.string :password_digest

      t.timestamps null: false
    end

    create_table :composite_name_entities do |t|
      t.string :email
      t.string :password_digest

      t.timestamps null: false
    end

    create_table :v1_users do |t|
      t.string :email, unique: true, null: false
      t.string :password_digest, null: false

      t.timestamps null: false
    end
  end
end
