module UsersHelper
  def avatar_for(user, variant_size)
    size_config = {
      small: { size: [66, 66], class: 'small-avatar' },
      middle: { size: [160, 160], class: 'avatar' }
    }

    variant = size_config[variant_size]
    image_source = user.avatar.attached? ? user.avatar.variant(resize_to_limit: variant[:size]) : 'blank_user_image.png'

    image_tag image_source, class: variant[:class], loding: 'lazy', data: { image_target: "image" }
  end
end
