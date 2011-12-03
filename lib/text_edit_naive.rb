module TextEditor
  class Document
    def initialize
      @contents = ""
      @snapshots = []
      @reverted  = []
    end
    
    attr_reader :contents

    # instead of recording the entire contents
    # in snapshots and reverted
    # record the add and remove actions themselves
    
    # structure of action to record:
    # { "add" => "text to add" }
    # { "rm" => "text to remove" }
    # with more time, this structure should be changed to an object
    
    def add_text(text, position=-1)
      snapshot(true)
      contents.insert(position, text)
    end

    def remove_text(first=0, last=contents.length)
      snapshot(true)
      contents.slice!(first...last)
    end

    #change snapshot to only record the change made
    def snapshot(clear_redo=false)
      @reverted = [] if clear_redo
      @snapshots << @contents.dup
    end

    #change reverted to only record t
    def undo
      return if @snapshots.empty?

      @reverted << @contents
      @contents = @snapshots.pop
    end

    def redo
      return if @reverted.empty?

      snapshot
      @contents = @reverted.pop
    end

  end
end
