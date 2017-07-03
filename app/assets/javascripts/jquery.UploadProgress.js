$.ajax({
    xhr: function(){
        var xhr = new window.XMLHttpRequest();
        // Handle progress
        //Upload progress
        xhr.upload.addEventListener("progress", function(evt){
            console.log('Uploading')
            if (evt.lengthComputable) {
                var percentComplete = evt.loaded / evt.total;
                //Do something with upload progress
                console.log(percentComplete);
            }
        }, false);
        //Download progress
        xhr.addEventListener("progress", function(evt){
            if (evt.lengthComputable) {
                var percentComplete = evt.loaded / evt.total;
                //Do something with download progress
                console.log(percentComplete);
            }
        }, false);

        return xhr;
    },
    complete:function(){
        console.log("Request finished.");
    }
});