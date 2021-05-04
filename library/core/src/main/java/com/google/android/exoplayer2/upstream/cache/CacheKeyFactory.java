/*
 * Copyright (C) 2018 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.google.android.exoplayer2.upstream.cache;

import com.google.android.exoplayer2.upstream.DataSpec;

/** Factory for cache keys. */
public interface CacheKeyFactory {

  /** Default {@link CacheKeyFactory}. */
  CacheKeyFactory DEFAULT = new CacheKeyFactory() {
    @Override
    public String buildCacheKey(DataSpec dataSpec) {
      return dataSpec.key != null ? dataSpec.key : dataSpec.uri.toString();
    }

    @Override
    @Deprecated
    public String buildLegacyCacheKey(DataSpec dataSpec) {
      // Legacy cache key
      // https://github.com/sky-uk/core-video-team-exoplayer/wiki/CVT-Contributions:-Features,-Backports,-Fixes-and-Workarounds#feature-parallel-segment-downloads
      return dataSpec.key != null ? dataSpec.key : dataSpec.toLegacyString() + "-" + + dataSpec.absoluteStreamPosition;
    }
  };

  /**
   * Returns the cache key of the resource containing the data defined by a {@link DataSpec}.
   *
   * <p>Note that since the returned cache key corresponds to the whole resource, implementations
   * must not return different cache keys for {@link DataSpec DataSpecs} that define different
   * ranges of the same resource. As a result, implementations should not use fields such as {@link
   * DataSpec#position} and {@link DataSpec#length}.
   *
   * @param dataSpec The {@link DataSpec}.
   * @return The cache key of the resource.
   */
  String buildCacheKey(DataSpec dataSpec);

  /**
   * @deprecated Legacy code. To be removed in future versions
   */
  @Deprecated
  default String buildLegacyCacheKey(DataSpec dataSpec) {
    return buildCacheKey(dataSpec);
  }
}
