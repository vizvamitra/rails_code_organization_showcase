ActiveAdmin.register Moderation::CommentFeed do
  config.batch_actions = false

  actions :index, :show
  menu label: "Moderation: Comment Feeds"

  scope :all, default: true
  scope :moderated
  scope :not_moderated
  scope :connection_error

  action_item :pause_moderation, only: :show, if: -> { resource.moderated? } do
    link_to(
      "Pause moderation",
      [:pause_moderation, :admin, resource],
      method: :post,
      class: "action-item-button danger",
      data: { confirm: "Are you sure?" }
    )
  end

  action_item :activate_moderation, only: :show, if: -> { !resource.moderated? } do
    link_to(
      "Activate moderation",
      [:activate_moderation, :admin, resource],
      method: :post,
      class: "action-item-button danger",
      data: { confirm: "Are you sure?" }
    )
  end

  filter :id
  filter :public_id_eq, label: "Public Id"
  filter :client
  filter :platform, as: :select, collection: Moderation::CommentFeed.platforms
  filter :title
  filter :created_at
  filter :updated_at

  index download_links: false do
    id_column
    column(:platform) { status_tag(_1.platform, class: _1.platform) }
    column(:title) do |comment_feed|
      link_to(comment_feed.title, [:admin, comment_feed])
    end
    column(:url) do
      a(href: _1.url, target: "_blank") do
        text_node(<<~HTML.html_safe)
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" style="width: 1.2em; height: 1.2em; min-width: 1.2em;" viewBox="0 0 24 24"><path d="M15 3h6v6M10 14 21 3M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/></svg>
        HTML
      end
    end
    column :moderated
    column(:connected) do
      status_tag(
        _1.connected,
        class: ('danger' if _1.moderated? && _1.disconnected?)
      )
    end
    column(:client, sortable: :client_id)
    actions
  end

  show do
    attributes_table_for(resource) do
      row :id
      row :client
      row(:public_id)
      row(:platform) { status_tag(_1.platform, class: _1.platform) }
      row :title
      row(:avatar) { image_tag(_1.avatar_url, size: "64x64", class: "rounded-full") }
      row(:url) do
        a(_1.url, href: _1.url, target: "_blank", class: "flex items-center gap-1") do
          text_node(<<~HTML.html_safe)
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" style="width: 1.2em; height: 1.2em; min-width: 1.2em;" viewBox="0 0 24 24"><path d="M15 3h6v6M10 14 21 3M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/></svg>
          HTML
          # link_to(_1.url, nil, target: "_blank")
        end
      end
      row :moderated
      row(:connected) do
        status_tag(
          _1.connected,
          class: ('danger' if _1.moderated? && _1.disconnected?)
        )
      end
      row :created_at
      row :updated_at
    end
  end

  member_action :pause_moderation, method: :post do
    Moderation::Interface.new.toggle_comment_feed_moderation(
      client_id: resource.client_id,
      comment_feed_id: resource.id,
      moderated: false
    )
    redirect_to request.referer, notice: "Moderation paused"
  end

  member_action :activate_moderation, method: :post do
    Moderation::Interface.new.toggle_comment_feed_moderation(
      client_id: resource.client_id,
      comment_feed_id: resource.id,
      moderated: true
    )
    redirect_to request.referer, notice: "Moderation activated"
  end
end
