package com.google.android.exoplayer2.offline;

// PEACOCK WORK AROUND FOR https://github.com/google/ExoPlayer/issues/9284
// REMOVE WHEN THIS ISSUE IS RESOLVED
public interface DashDownloadFilter {
    boolean isPrimaryTrack();
}
