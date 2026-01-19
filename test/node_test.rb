# frozen_string_literal: true

require_relative "test_helper"

describe Node do
  describe "#root_id" do
    it "generates a unique ID for a new node" do
      node = Node.new
      expect(node.root_id).wont_be_nil
      expect(node.root_id).must_be_instance_of(String)
    end

    it "generates different IDs for different nodes" do
      node1 = Node.new
      node2 = Node.new
      expect(node1.root_id).wont_equal(node2.root_id)
    end

    it "returns the same ID when called multiple times" do
      node = Node.new
      id1 = node.root_id
      id2 = node.root_id
      expect(id1).must_equal(id2)
    end
  end

  describe "#change_root" do
    it "sets a parent for a root node" do
      node_a = Node.new
      node_b = Node.new

      node_a.change_root(node_b)

      expect(node_a.root_id).must_equal(node_b.root_id)
    end

    it "propagates to the root when setting on a non-root node" do
      node_a = Node.new
      node_b = Node.new
      node_c = Node.new

      node_a.change_root(node_b)
      node_a.change_root(node_c)

      expect(node_a.root_id).must_equal(node_c.root_id)
      expect(node_b.root_id).must_equal(node_c.root_id)
    end
  end

  describe "#root" do
    it "returns self when node has no parent" do
      node = Node.new
      expect(node.root).must_equal(node)
    end

    it "returns the root node when there is a parent chain" do
      node_a = Node.new
      node_b = Node.new
      node_c = Node.new

      node_a.change_root(node_b)
      node_b.change_root(node_c)

      expect(node_a.root).must_equal(node_c)
      expect(node_b.root).must_equal(node_c)
    end
  end
end
