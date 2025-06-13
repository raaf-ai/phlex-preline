// Official Preline UI File Upload initialization
// Requires Dropzone.js and Preline UI JavaScript libraries

// Initialize file upload components when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  // Initialize all file upload instances
  const fileUploadElements = document.querySelectorAll('[id^="hs-file-upload"]');
  
  fileUploadElements.forEach(element => {
    if (typeof HSFileUpload !== 'undefined') {
      HSFileUpload.getInstance(element, true);
    } else {
      console.warn('HSFileUpload not found. Please ensure Preline UI JavaScript is loaded.');
    }
  });
});

// Auto-reinitialize when new file upload elements are added dynamically
if (typeof HSFileUpload !== 'undefined') {
  // Use MutationObserver to watch for dynamically added file upload elements
  const observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      mutation.addedNodes.forEach(function(node) {
        if (node.nodeType === 1) { // Element node
          const fileUploads = node.querySelectorAll ? node.querySelectorAll('[id^="hs-file-upload"]') : [];
          fileUploads.forEach(element => {
            HSFileUpload.getInstance(element, true);
          });
          
          // Check if the added node itself is a file upload
          if (node.id && node.id.startsWith('hs-file-upload')) {
            HSFileUpload.getInstance(node, true);
          }
        }
      });
    });
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
}

// Export for manual initialization if needed
window.PrelineFileUpload = {
  init: function(selector) {
    const elements = document.querySelectorAll(selector || '[id^="hs-file-upload"]');
    elements.forEach(element => {
      if (typeof HSFileUpload !== 'undefined') {
        HSFileUpload.getInstance(element, true);
      }
    });
  },
  
  destroy: function(selector) {
    const elements = document.querySelectorAll(selector || '[id^="hs-file-upload"]');
    elements.forEach(element => {
      if (typeof HSFileUpload !== 'undefined') {
        const instance = HSFileUpload.getInstance(element);
        if (instance) {
          instance.destroy();
        }
      }
    });
  }
};