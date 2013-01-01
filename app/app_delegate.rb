# -*- coding: utf-8 -*-

class AppDelegate
  def self.v # for console debug
    delegate = UIApplication.sharedApplication.delegate
    delegate.instance_variable_get('@view_controller')
  end

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @view_controller = MyViewController.alloc.initWithNibName(nil, bundle:nil)
    @window.rootViewController = @view_controller
    @window.makeKeyAndVisible
    true
  end
end

class MyViewController < UIViewController
  def _initUI()
    # backgroundColor
    self.view.backgroundColor = UIColor.grayColor

    text_field_height = 31
    frame = self.view.frame

    # bubbleTable
    @bubbleTable = UIBubbleTableView.new.tap do |bt|
      bt.frame = [[0, 0], [frame.size.width, frame.size.height - text_field_height]]
      bt.snapInterval = 120
      bt.showAvatars = true
      bt.typingBubble = NSBubbleTypingTypeSomebody
      bt.backgroundColor = UIColor.whiteColor
    end
    self.view.addSubview(@bubbleTable)

    @textField = UITextField.new.tap do |tf|
      tf.frame = [[0, frame.size.height - text_field_height], [frame.size.width, text_field_height]]
      tf.font = UIFont.systemFontOfSize(14)
      tf.borderStyle = UITextBorderStyleRoundedRect
      tf.backgroundColor = UIColor.whiteColor
      tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter
      tf.autocorrectionType = UITextAutocorrectionTypeNo
      tf.keyboardType = UIKeyboardTypeURL
      tf.returnKeyType = UIReturnKeySend
      tf.delegate = self
      tf.text = 'hey'
    end
    self.view.addSubview(@textField)
  end

  def viewDidLoad
    super
    self._initUI()

    @bubbleDataSource = MyBubbleDataSource.new
    @bubbleTable.bubbleDataSource = @bubbleDataSource
    @bubbleTable.reloadData()

    NSNotificationCenter.defaultCenter.addObserver(self, selector:'keyboardWillShow:',
                                                   name:UIKeyboardWillShowNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector:'keyboardWillHide:',
                                                   name:UIKeyboardWillHideNotification, object:nil)
  end

  def _keyboardWillMove(n)
    info = n.userInfo
    bgnRect = info[UIKeyboardFrameBeginUserInfoKey].CGRectValue
    endRect = info[UIKeyboardFrameEndUserInfoKey  ].CGRectValue
    dy = endRect.origin.y - bgnRect.origin.y

    UIView.animateWithDuration(0.2, animations:lambda{
      f = @textField.frame
      f.origin.y += dy
      @textField.frame = f

      f = @bubbleTable.frame
      f.size.height += dy
      @bubbleTable.frame = f
    })
  end

  def keyboardWillShow(n)
    _keyboardWillMove(n)
  end

  def keyboardWillHide(n)
    _keyboardWillMove(n)
  end

  def textFieldShouldReturn(tf)
    tf.resignFirstResponder
    if tf.text != ""
      data = NSBubbleData.dataWithText(tf.text, date:Time.now, type:BubbleTypeMine)
      @bubbleDataSource.addData(data)
      @bubbleTable.reloadData()
      tf.text = ""
    end
    true
  end

  class MyBubbleDataSource # UIBubbleTableViewDataSource
    def initialize
      @list = []

      heyBubble = NSBubbleData.dataWithText("Hey, halloween is soon", date:Time.now-300, type:BubbleTypeSomeoneElse)
      heyBubble.avatar = UIImage.imageNamed("avatar1.png")

      photoBubble = NSBubbleData.dataWithImage(UIImage.imageNamed("halloween.jpg"),
                                               date:Time.now-290, type:BubbleTypeSomeoneElse)
      photoBubble.avatar = UIImage.imageNamed("avatar1.png")

      replyBubble = NSBubbleData.dataWithText("Wow.. Really cool picture out there. iPhone 5 has really nice camera, yeah?",
                                              date:Time.now-5, type:BubbleTypeMine)
      replyBubble.avatar = nil

      self.addData(heyBubble)
      self.addData(photoBubble)
      self.addData(replyBubble)
    end

    def addData(data)
      @list.unshift(data)
    end

    def rowsForBubbleTable(bubbleTable)
      @list.size
    end

    def bubbleTableView(bubbleTable, dataForRow:row) # NSBubbleData
      @list[row]
    end
  end
end
