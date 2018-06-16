RSpec.describe Show, type: :model do

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:start_at) }
  it { should validate_presence_of(:stop_at) }

end