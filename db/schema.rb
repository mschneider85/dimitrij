ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.tables.include? 'channels'
    create_table :channels, id: false do |t|
      t.bigint :id, null: false, index: { unique: true }
      t.bigint :server_id
      t.integer :language, null: false, default: 0
      t.string :name
      t.datetime :reminded_at

      t.timestamps null: false
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'servers'
    create_table :servers, id: false do |t|
      t.bigint :id, null: false, index: { unique: true }
      t.string :name

      t.timestamps null: false
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'users'
    create_table :users, id: false do |t|
      t.bigint :id, null: false, index: { unique: true }
      t.string :name
      t.integer :discriminator

      t.timestamps null: false
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'teams'
    create_table :teams do |t|
      t.bigint :channel_id, null: false
      t.string :player_ids
      t.timestamps null: false
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'teams_users'
    create_table :teams_users do |t|
      t.belongs_to :team
      t.bigint :user_id
      t.timestamps null: false
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'games'
    create_table :games do |t|
      t.bigint :channel_id, null: false
      t.belongs_to :team_a
      t.belongs_to :team_b
      t.string :winner
      t.timestamps null: false
    end
  end
end
