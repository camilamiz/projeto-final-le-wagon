class CreateAuthorships < ActiveRecord::Migration[5.2]
  def change
    create_table :authorships do |t|
      t.references :project, foreign_key: true
      t.references :councillor, foreign_key: true

      t.timestamps
    end
  end
end
