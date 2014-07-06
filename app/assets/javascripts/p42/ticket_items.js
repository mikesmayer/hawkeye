$(document).ready(function(){
	if( $('#gdrive_file_list').length > 0 ){
		console.log("Getting files from google drive");
		$.ajax({
			url: "file_list",
			cache: false,
			success: function(html){
				console.log(html);
				$('#gdrive_file_list').html(html);
			}
		});
	}
});

