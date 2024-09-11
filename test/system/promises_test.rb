require "application_system_test_case"

class PromisesTest < ApplicationSystemTestCase
  setup do
    @promise = promises(:one)
  end

  test "visiting the index" do
    visit promises_url
    assert_selector "h1", text: "Promises"
  end

  test "should create promise" do
    visit promises_url
    click_on "New promise"

    fill_in "Created at", with: @promise.created_at
    fill_in "Description", with: @promise.description
    fill_in "Politician", with: @promise.politician_id
    fill_in "Status", with: @promise.status
    fill_in "Title", with: @promise.title
    fill_in "Updated at", with: @promise.updated_at
    click_on "Create Promise"

    assert_text "Promise was successfully created"
    click_on "Back"
  end

  test "should update Promise" do
    visit promise_url(@promise)
    click_on "Edit this promise", match: :first

    fill_in "Created at", with: @promise.created_at
    fill_in "Description", with: @promise.description
    fill_in "Politician", with: @promise.politician_id
    fill_in "Status", with: @promise.status
    fill_in "Title", with: @promise.title
    fill_in "Updated at", with: @promise.updated_at
    click_on "Update Promise"

    assert_text "Promise was successfully updated"
    click_on "Back"
  end

  test "should destroy Promise" do
    visit promise_url(@promise)
    click_on "Destroy this promise", match: :first

    assert_text "Promise was successfully destroyed"
  end
end
