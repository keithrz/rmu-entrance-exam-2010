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
    # [:add , "text to add", -1]
    # [ :rm , "text to remove", 2]
    # with more time, this structure should be changed to an object
    ## init 
    # add Hello
    # [:add, "Hello", -1]
    # undo calls remove_text 0, "Hello".length
    #
    ## init 
    # add Hello
    # [:add, "Hello", -1]
    # add World
    # [:add, " World", -1]
    # undo calls remove_text 5, "Hello".length
    # 5 == the length of content before add (special case for position = -1)
    #
    ## init
    # [:add, "Hal", -1]
    # [:add, "skel", 2]
    # undo calls remove_text 2, "skel".length
    #
    ## init
    # call add_Text "Hello"
    # call remove_text(1,3)
    # [:rm, "el", 1] 
    # undo calls add_text "el", 1
    # 
    # redo is similar, except in reverse
    #   call add_text when the action is :add
    #   call remove_text when the action is :rm
    
    # with more time,
    # add_text(text, position) should be public
    # add_text(text, position, track_undo_redo) should be private
    # with common code in a private method
    def add_text(text, position=-1, track_undo_redo=true)
      snapshot(track_undo_redo, :add, text, position == -1 ? @contents.length : position)
      contents.insert(position, text)
    end

    # with more time,
    # remove_text(first, last) should be public
    # remove_text(first, last, track_undo_redo) should be private
    # with common code in a private method
    def remove_text(first=0, last=contents.length, track_undo_redo=true)
      # open question to product owner: 
      #  any issues with removing the text
      #  before recording the snapshot?
      removed_text = contents.slice!(first...last)
      snapshot(track_undo_redo, :rm, removed_text, first)
    end

    #changed snapshot to only record the change made
    def snapshot(track_undo_redo=false, action=:rm, text="", position=0)
      if track_undo_redo then
        @reverted = [] 
        @snapshots << [action, text, position]
      end
    end

    #changed reverted to only record the change made
    def undo
      return if @snapshots.empty?

      # admittedly, the action array is confusing
      # an object would be much more straightforward
      action = @snapshots.pop
      if action[0] == :add then
        remove_text action[2], action[2] + action[1].length, false
      else
        add_text action[1], action[2], false
      end
      @reverted << action
    end

    def redo
      return if @reverted.empty?

      # admittedly, the action array is confusing
      # an object would be much more straightforward
      action = @reverted.pop
      if action[0] == :add then
        add_text action[1], action[2], false
      else
        remove_text action[2], action[2] + action[1].length, false
      end
      @snapshots << action
    end
  end
end
