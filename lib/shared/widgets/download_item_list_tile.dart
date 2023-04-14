import 'package:cached_network_image/cached_network_image.dart';
import 'package:fetchme/fetchme.dart';
import 'package:flutter/material.dart';
import 'package:youtube_downloader/domain/entities/download_item.dart';
import 'package:youtube_downloader/shared/styles.dart';
import 'package:youtube_downloader/shared/utils.dart';
import 'package:youtube_downloader/shared/widgets/icon_button.dart';

class DownloadItemListTile extends StatelessWidget {
  final DownloadItemEntity downloadItem;
  final void Function(int taskId) onPause;
  final void Function(int taskId) onResume;
  final void Function(int taskId) onRetry;
  final bool isSelected;

  const DownloadItemListTile({
    Key? key,
    required this.downloadItem,
    required this.onPause,
    required this.onResume,
    required this.onRetry,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var status = downloadItem.status;
    print(status.toString());
    return Container(
      margin: const EdgeInsets.all(6),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Stack(children: [
            CachedNetworkImage(
              imageUrl: downloadItem.thumbnailLink,
              imageBuilder: (context, provider) => Container(
                width: 100,
                height: 75,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: provider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, provider) => Image.asset(
                'assets/images/placeholder.jpeg',
                width: 100,
                height: 75,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Text(
                Duration(seconds: downloadItem.duration)
                    .toString()
                    .replaceAll(RegExp(r'[.]\d+'), ""),
                style: const TextStyle(
                    backgroundColor: Colors.black38, color: Colors.white70),
              ),
            ),
            !isSelected
                ? const SizedBox()
                : Container(
                    width: 100,
                    height: 75,
                    color: Colors.cyan.withAlpha(100),
                    child: const Icon(Icons.done_outline, size: 42),
                  )
          ]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(7.0, 3.0, 7.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    downloadItem.title,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          downloadItem.isAudio?"MP3":downloadItem.format.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(3))),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        downloadItem.isAudio?"🎧 Audio":downloadItem.quality,
                        style: Styles.labelTextStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            [
                              DownloadTaskStatus.complete.value,
                              DownloadTaskStatus.running.value,
                              DownloadTaskStatus.paused.value
                            ].contains(status)
                                ? downloadItem.getProgressPercentage()
                                : status == DownloadTaskStatus.failed.value
                                    ? 'Disconnected'
                                    : 'Waiting in queue',
                            style: Styles.labelTextStyle.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                      buildActionButton()
                    ],
                  ),
                  // Text(
                  //     downloadItem.status == DownloadTaskStatus.failed.value
                  //         ? "Error!"
                  //         : _format((downloadItem.downloaded /
                  //                     downloadItem.size) *
                  //                 100) +
                  //             '%'),
                  downloadItem.isCompleted()
                      ? const SizedBox()
                      : Stack(children: [
                          LinearProgressIndicator(
                            minHeight: 11.7,
                            backgroundColor: Colors.black12,
                            color: status == DownloadTaskStatus.complete.value
                                ? Colors.green
                                : Colors.blue,
                            value:
                                (downloadItem.downloaded / downloadItem.size),
                          ),
                          Text(
                            ' ${humanReadableByteCountBin(downloadItem.downloaded)}/' +
                                (downloadItem.size == -1
                                    ? ' ?'
                                    : humanReadableByteCountBin(
                                        downloadItem.size)),
                            style: Styles.labelTextStyle.copyWith(fontSize: 10),
                          )
                        ])
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButton() {
    var icon = downloadItem.status == DownloadTaskStatus.paused.value
        ? Icons.play_arrow
        : downloadItem.status == DownloadTaskStatus.complete.value
            ? Icons.check
            : downloadItem.status == DownloadTaskStatus.failed.value
                ? Icons.restart_alt
                : downloadItem.status == DownloadTaskStatus.queued.value
                    ? Icons.access_time_filled
                    : Icons.pause;

    var color = downloadItem.status == DownloadTaskStatus.paused.value
        ? Colors.green
        : downloadItem.status == DownloadTaskStatus.complete.value
            ? Colors.greenAccent
            : downloadItem.status == DownloadTaskStatus.failed.value
                ? Colors.amber
                : Colors.black45;

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: NIconButton(
        padding: 2.0,
        icon: icon,
        iconColor: color,
        onPressed: icon == Icons.warning_rounded
            ? null
            : () {
                if (downloadItem.status == null) return;
                if (downloadItem.status == DownloadTaskStatus.running.value) {
                  onPause(downloadItem.taskId!);
                } else if (downloadItem.status ==
                    DownloadTaskStatus.paused.value) {
                  onResume(downloadItem.taskId!);
                } else if (downloadItem.status ==
                        DownloadTaskStatus.canceled.value ||
                    downloadItem.status == DownloadTaskStatus.failed.value) {
                  onRetry(downloadItem.taskId!);
                }
              },
      ),
    );
  }
}
