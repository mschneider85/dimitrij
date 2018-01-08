ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.tables.include? 'channels'
    create_table :channels do |t|
      t.string :channel_id, index: { unique: true }
      t.integer :language, null: false, default: 0
      t.datetime :reminded_at

      t.timestamps null: false
    end
  end
end
