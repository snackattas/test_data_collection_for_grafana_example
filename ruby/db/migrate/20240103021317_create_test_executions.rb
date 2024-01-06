class CreateTestExecutions < ActiveRecord::Migration[7.1]
  def change
    create_table :test_executions do |t|
      t.timestamps
      t.text :test_groups, array: true, default: []
      t.string :build_id
      # https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables
      t.string :branch
      t.string :url
      t.string :commit_author
      t.string :git_hash
      t.integer :parallel_processes, null: false, default: 1
      t.boolean :cd, null: false, default: false
      t.boolean :rerun, null: false, default: false
      t.string :status
      t.boolean :error
      t.timestamp :finished_at
    end
    add_index :test_executions, [:build_id, :rerun], unique: true
  end
end
