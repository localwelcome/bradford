require "rails_helper"

RSpec.feature "New user is invited by a friend", :type => :feature do
  before do
    @event = Event.create!(name: "Test Event 1", starts_at: "01/01/2018 15:30".to_time)
    @inviter = Person.create!(name: "Test Invitee")
    @attendance = Attendance.create!(event: @event, invitee: @inviter, state: 'new')
  end
  scenario "User clicks yes" do
    visit "/invites/#{@attendance.code}"

    expect(page).to have_text("Hi! Test Invitee has invited you to join them to meet some refugees.")
    expect(page).to have_text("1st Jan")
    expect(page).to have_text("3:30PM - 5:30PM")

    fill_in "Name", with: "New Test"
    fill_in "Phone number", with: "0123456789"
    click_button "I can come!"

    expect(page).to have_text("Great! Looking forward to it.")
    reloaded_attendance = Attendance.find(@attendance.id)
    expect(reloaded_attendance.state).to eq('confirmed')
    sharing_invite = reloaded_attendance.shareable_invites.first
    expect(sharing_invite).to eq(nil)
  end

  scenario "User clicks no" do
    visit "/invites/#{@attendance.code}"

    expect(page).to have_text("Hi! Test Invitee has invited you to join them to meet some refugees")
    expect(page).to have_text("1st Jan")
    expect(page).to have_text("3:30PM - 5:30PM")
    click_button "I can't come"

    expect(page).to have_text("That's a shame")
    reloaded_attendance = Attendance.find(@attendance.id)
    expect(reloaded_attendance.state).to eq('rejected')
    sharing_invite = reloaded_attendance.shareable_invites.first
    expect(sharing_invite).to eq(nil)
  end
end