module UsersHelper
  def avatar_for(user, variant_size)
    size_config = {
      small: { size: [33, 33], class: 'small-avatar' },
      middle: { size: [80, 80], class: 'avatar' }
    }

    variant = size_config[variant_size]
    image_source = user.avatar.attached? ? user.avatar.variant(resize_to_limit: variant[:size]) : 'blank_user_image.png'

    image_tag image_source, class: variant[:class]
  end
end
