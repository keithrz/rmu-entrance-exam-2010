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
    # ["add" , "text to add", -1]
    # [ "rm" , "text to remove", 2]
    # with more time, this structure should be changed to an object
    ## init 
    # add Hello
    # ["add", "Hello", -1]
    # undo calls remove_text 0, "Hello".length
    #
    ## init 
    # add Hello
    # ["add", "Hello", -1]
    # add World
    # ["add", " World", -1]
    # undo calls remove_text 5, "Hello".length
    # 5 == the length of content before add (special case for position = -1)
    #
    ## init
    # ["add", "Hal", -1]
    # ["add", "skel", 2]
    # undo calls remove_text 2, "skel".length
    #
    ## init
    # call add_Text "Hello"
    # call remove_text(1,3)
    # ["rm", "el", 1] 
    # undo calls add_text "el", 1
    # 
    
    
    def add_text(text, position=-1, snapshot_needed=true)
      if snapshot_needed then
        snapshot(true, "add", text, position == -1 ? @contents.length : position)
      end
      contents.insert(position, text)
    end

    def remove_text(first=0, last=contents.length, snapshot_needed=true)
      # open question to product owner: 
      #  any issues with removing the text
      #  before recording the snapshot?
      removed_text = contents.slice!(first...last)
      if snapshot_needed then
        snapshot(true, "rm", removed_text, first)
      end
    end

    #change snapshot to only record the change made
    def snapshot(clear_redo=false, action="rm", text="", position=0)
      @reverted = [] if clear_redo
      @snapshots << [action, text, position]
    end

    #change reverted to only record t
    def undo
      return if @snapshots.empty?

#      @reverted << @contents
      # admittedly, the action array is confusing
      # an object would be much more straightforward
      action = @snapshots.pop
      if action[0] == "add" then
        remove_text action[2], action[2] + action[1].length, false
      else
        add_text action[1], action[2], false
      end
    end

    def redo
      return if @reverted.empty?

      snapshot
      @contents = @reverted.pop
    end

  end
end
