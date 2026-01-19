# frozen_string_literal: true

require "securerandom"

class Node
  def change_root(node)
    if @parent.nil?
      @parent = node
      return
    end

    @parent&.change_root(node)
  end

  def root
    @parent&.root || self
  end

  def root_id
    root.id
  end

  protected

  def id
    @id ||= SecureRandom.uuid
  end
end
