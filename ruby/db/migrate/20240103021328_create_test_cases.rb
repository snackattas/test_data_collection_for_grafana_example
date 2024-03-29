class CreateTestCases < ActiveRecord::Migration[7.1]
  def change
    create_table :test_cases do |t|
      t.timestamps
      t.integer :test_execution, null: false
      t.string :status, null: false
      t.integer :parallel_process, null: false
      t.string :name, null: false
      t.string :path, null: false
      t.string :exception_class
      t.string :exception_message
      t.string :exception_traceback
      t.string :pending_message
      t.json :data, default: {}
      t.timestamp :finished_at
    end
    add_index :test_cases, :test_execution
  end
end
