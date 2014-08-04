class CreateJobLogs < ActiveRecord::Migration
  def change
    create_table :job_logs do |t|
      t.string :job_type
      t.datetime :date_run
      t.string :folder_name
      t.string :file_name
      t.string :method_name
      t.string :model_name
      t.string :error_ids
      t.integer :num_processed
      t.integer :num_errors
      t.integer :num_updated
      t.integer :num_created
    end
  end
end
