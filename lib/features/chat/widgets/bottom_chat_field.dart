import 'dart:async';
import 'dart:io';

import 'package:chatsma_flutter/common/enums/message_enum.dart';
import 'package:chatsma_flutter/common/providers/message_reply_provider.dart';
import 'package:chatsma_flutter/common/utils/utils.dart';
import 'package:chatsma_flutter/features/chat/controller/chat_controller.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../common/utils/colors.dart';
import 'message_reply_preview.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroupChat;

  const BottomChatField({
    Key? key,
    required this.receiverUserId,
    required this.isGroupChat,
  }) :
        super(key: key);

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isShowSendButton = false;
  FlutterSoundRecorder? _soundRecorder;
  bool isShowEmojiContainer = false;
  bool isRecorderInit = false;
  bool isRecording = false;
  final FocusNode myFocusNode = FocusNode();
  int _recordSeconds = 0;
  Timer? _timer;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  // Recorder audio
  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission denied');
    }
    await _soundRecorder!.openRecorder();
    isRecorderInit = true;
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordSeconds++;
      });
    });
  }

  // Recorder audio
  void stopTimer() {
    _timer?.cancel();
    _recordSeconds = 0;
  }

  // Recorder audio & send message
  void sendTextMessage() async {
    if (isShowSendButton) {
      ref.read(chatControllerProvider).sendTextMessage(
            context,
            _textController.text.trim(),
            widget.receiverUserId,
            widget.isGroupChat,

          );
      setState(() {
        _textController.text = '';
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecorderInit) {
        return;
      }
      if (isRecording) {
        stopTimer();
        await _soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(
          toFile: path,
        );
        startTimer();
      }
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void sendFileMessage(File file, MessageEnum messageEnum) {
    ref.read(chatControllerProvider).sendFileMessage(
          context,
          file,
          widget.receiverUserId,
          messageEnum,
          widget.isGroupChat,
        );
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  void selectGIF() async {
    final gif = await pickGIF(context);
    if (gif != null) {
      ref.read(chatControllerProvider).sendGIF(
            context,
            gif.url,
            widget.receiverUserId,
            widget.isGroupChat,
          );
    }
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyboard() => myFocusNode.requestFocus();
  void hideKeyboard() => myFocusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

// enter key from keyboard
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textController.dispose();
    myFocusNode.dispose();
    /*_soundRecorder!.closeRecorder(); // recorder audio
    isRecorderInit  = false; // recorder audio*/

    if (isRecorderInit) {
      _soundRecorder!.closeRecorder();
    }
    stopTimer(); // dừng Timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    final isShowMessageReply = messageReply != null;
    return Column(
      children: [
        isShowMessageReply ? const MessageReplyPreview() : const SizedBox(),
        Row(
          children: [
            IconButton(
              onPressed: () => _showAttachmentOptions(context),
              icon: const Icon(
                Icons.add_outlined,
                color: bgColorAll,
              ),
            ),
            Expanded(
              // show send or voice button
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: SingleChildScrollView(
                  child: TextFormField(
                    controller: _textController, // enter key from keyboard
                    focusNode: myFocusNode, // enter key from keyboard
                    maxLines: 6,
                    minLines: 1,
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        setState(() {
                          isShowSendButton = true;
                        });
                      } else {
                        setState(() {
                          isShowSendButton = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: mobileChatBoxColor,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: SizedBox(
                          width: 5,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: toggleEmojiKeyboardContainer,
                                icon: const Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: bgColorAll,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      hintText: 'Type a message!',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),

                    //assign event enter key from keyboard (aa1)
                    onFieldSubmitted: (value) {
                      sendTextMessage(); // add here
                    }, //(aa1)
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 5.0,
                right: 5,
                left: 5,
              ),
              child: isShowSendButton
                  ? GestureDetector(
                      onTap: sendTextMessage,
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFF128C7E),
                        radius: 25,
                        child: Icon(Icons.send),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: selectImage,
                          child: const Icon(
                            Icons.image_rounded,
                            size: 25,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: sendTextMessage,
                          child: Row(
                            children: [
                              Icon(isRecording ? Icons.close : Icons.mic,
                                  size: 25),
                              if (isRecording)
                                Text(
                                    '${_recordSeconds ~/ 60}:${_recordSeconds % 60}'),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
        isShowEmojiContainer
            ? SizedBox(
                height: 310,
                child: EmojiPicker(
                  onEmojiSelected: ((category, emoji) {
                    setState(() {
                      _textController.text = _textController.text + emoji.emoji;
                    });
                    if (!isShowSendButton) {
                      setState(() {
                        isShowSendButton = true;
                      });
                    }
                  }),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  void _showAttachmentOptions(context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Photo Library'),
                  onTap: () {
                    selectImage();
                    Navigator.pop(context);
                  }),
              const Divider(
                height: 5,
              ),
              ListTile(
                leading: const Icon(Icons.video_camera_front_outlined),
                title: const Text('Video Library'),
                onTap: () {
                  selectVideo();
                  Navigator.pop(context);
                },
              ),
              const Divider(
                height: 5,
              ),
              ListTile(
                leading: const Icon(Icons.gif_box_outlined),
                title: const Text('Gif'),
                onTap: selectGIF,
              ),
              const Divider(
                height: 5,
              ),
              ListTile(
                leading: const Icon(Icons.attach_file_outlined),
                title: const Text('Unk'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const Divider(
                height: 5,
                thickness: 3,
              ),
              ListTile(
                leading: const Icon(Icons.close_outlined),
                title: const Text('Close'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),

        );
      },
    );
  }

} //class
