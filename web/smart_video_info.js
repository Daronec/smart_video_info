// JavaScript implementation for Web platform
class SmartVideoInfoWeb {
  constructor() {
    this.videoElement = null;
  }

  // Extract metadata from video URL
  async getInfo(url) {
    return new Promise((resolve, reject) => {
      // Validate URL
      if (!url.startsWith('http://') && !url.startsWith('https://') && !url.startsWith('blob:')) {
        reject({
          success: false,
          error: 'Web platform only supports URLs (http://, https://, blob:)'
        });
        return;
      }

      // Create video element
      const video = document.createElement('video');
      video.preload = 'metadata';
      video.muted = true;
      video.style.display = 'none';
      
      // Add to DOM
      document.body.appendChild(video);

      // Timeout handler
      const timeoutId = setTimeout(() => {
        video.remove();
        reject({
          success: false,
          error: 'Metadata extraction timed out'
        });
      }, 10000);

      // Success handler
      video.addEventListener('loadedmetadata', () => {
        clearTimeout(timeoutId);
        
        try {
          const metadata = this.extractMetadata(video, url);
          video.remove();
          resolve({
            success: true,
            data: metadata
          });
        } catch (error) {
          video.remove();
          reject({
            success: false,
            error: error.message || 'Failed to extract metadata'
          });
        }
      });

      // Error handler
      video.addEventListener('error', () => {
        clearTimeout(timeoutId);
        video.remove();
        reject({
          success: false,
          error: video.error ? video.error.message : 'Failed to load video'
        });
      });

      // Load video
      video.src = url;
    });
  }

  // Extract metadata from video element
  extractMetadata(video, url) {
    // Get video dimensions
    const width = video.videoWidth;
    const height = video.videoHeight;

    if (width === 0 || height === 0) {
      throw new Error('Invalid video dimensions');
    }

    // Get duration in milliseconds
    const duration = Math.round(video.duration * 1000);

    // Extract container format from URL
    const urlPath = new URL(url, window.location.href).pathname;
    const pathParts = urlPath.split('.');
    const container = pathParts.length > 1 ? pathParts[pathParts.length - 1].toLowerCase() : 'unknown';

    // Detect codec from URL/MIME type
    let codec = 'unknown';
    if (url.includes('.mp4') || url.includes('.m4v')) {
      codec = 'h264';
    } else if (url.includes('.webm')) {
      codec = 'vp8';
    } else if (url.includes('.ogv')) {
      codec = 'theora';
    }

    // Check for audio tracks
    const hasAudio = video.mozHasAudio || 
                     Boolean(video.webkitAudioDecodedByteCount) ||
                     Boolean(video.audioTracks && video.audioTracks.length > 0);

    // Count streams
    let streamCount = 1; // At least video track
    if (hasAudio) {
      streamCount += video.audioTracks ? video.audioTracks.length : 1;
    }

    // Check for text tracks (subtitles)
    const hasSubtitles = video.textTracks && video.textTracks.length > 0;

    // Build metadata object
    const metadata = {
      width: width,
      height: height,
      duration: duration,
      codec: codec,
      bitrate: 0, // Not available in Web API
      fps: 30.0, // Default assumption
      rotation: 0, // Not available in Web API
      container: container,
      hasAudio: hasAudio,
      hasSubtitles: hasSubtitles,
      streamCount: streamCount
    };

    // Add audio metadata if present
    if (hasAudio) {
      metadata.audioCodec = 'unknown';
      metadata.sampleRate = 44100; // Default assumption
      metadata.channels = 2; // Default stereo assumption
    }

    return metadata;
  }

  // Extract metadata from multiple videos
  async getBatch(urls) {
    const results = [];
    
    for (const url of urls) {
      try {
        const result = await this.getInfo(url);
        results.push(JSON.stringify(result));
      } catch (error) {
        throw error;
      }
    }
    
    return results;
  }
}

// Export for use in Dart
window.SmartVideoInfoWeb = SmartVideoInfoWeb;
