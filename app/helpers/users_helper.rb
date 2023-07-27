module UsersHelper
  def avatar_for(user, variant_size)
    if user.avatar.attached?
      case variant_size
      when :small
        image_tag user.avatar.variant(resize_to_limit: [33, 33]), class: 'small-avatar'
      when :middle
        image_tag user.avatar.variant(resize_to_limit: [80, 80]), class: 'avatar'
      end
    else
      case variant_size
      when :small
        image_tag 'blank_user_image.png', class: 'small-avatar'
      when :middle
        image_tag 'blank_user_image.png', class: 'avatar'
      end
    end
  end
end
