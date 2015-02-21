include Warden::Test::Helpers
Warden.test_mode!

# Feature: Map page
#   As a user
#   I want to visit the map page
#   So I can see local tweets
feature 'Map page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User sees own profile
  #   Given I am signed in
  #   When I visit the user profile page
  #   Then I see my own email address
  scenario 'user sees map' do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)
    visit map_display_index_path
    expect(page).to have_content 'Tweetly.me'
  end

end
