require "application_system_test_case"

class CommentsTest < ApplicationSystemTestCase
  setup do
    @comment = comments(:one)
  end

  test "visiting the index" do
    visit comments_url
    assert_selector "h1", text: "Comments"
  end

  test "should create comment" do
    visit comments_url
    click_on "New comment"

    fill_in "Content", with: @comment.content
    fill_in "Created at", with: @comment.created_at
    fill_in "Promise", with: @comment.promise_id
    fill_in "Updated at", with: @comment.updated_at
    fill_in "User", with: @comment.user_id
    click_on "Create Comment"

    assert_text "Comment was successfully created"
    click_on "Back"
  end

  test "should update Comment" do
    visit comment_url(@comment)
    click_on "Edit this comment", match: :first

    fill_in "Content", with: @comment.content
    fill_in "Created at", with: @comment.created_at
    fill_in "Promise", with: @comment.promise_id
    fill_in "Updated at", with: @comment.updated_at
    fill_in "User", with: @comment.user_id
    click_on "Update Comment"

    assert_text "Comment was successfully updated"
    click_on "Back"
  end

  test "should destroy Comment" do
    visit comment_url(@comment)
    click_on "Destroy this comment", match: :first

    assert_text "Comment was successfully destroyed"
  end
end
