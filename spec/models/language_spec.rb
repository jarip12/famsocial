# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  title      :string
#  users_id   :integer
#  shows_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Language, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
