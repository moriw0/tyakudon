module LikesHelper
  # Check if user has liked a record (N+1 safe)
  # Uses preloaded likes association
  def user_liked_record?(user, record)
    return false unless user

    record.likes.any? { |like| like.user_id == user.id }
  end

  # Find user's like for a record (N+1 safe)
  # Uses preloaded likes association
  def user_like_for_record(user, record)
    return nil unless user

    record.likes.find { |like| like.user_id == user.id }
  end
end
