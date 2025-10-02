let SpawnableObjs = {}

window.addEventListener('message', function (event) {
	if (event.data.type === "OpenUI") {
		$("#body").fadeIn(300)
		$("#main-object-modal").modal("show")
	}
});

function CloseUI() {
	$("body").fadeOut(0)
	$.post('https://objectspawner/close', JSON.stringify({}));
}

document.onkeydown = function (data) {
	if (data.which == 27) { // Escape key
		CloseUI()
	}
};

$(document).ready(function () {
	$("body").fadeOut(0)
})

function CreateObject() {
	let objLabel = $("#create-object-label").val()
	let objModel = $("#create-object-model").val()
	let objDistance = $("#create-object-distance").val()

	$.post('https://objectspawner/CreateObject', JSON.stringify({
		label: objLabel,
		model: objModel,
		distance: parseInt(objDistance),
	}));

	$("#create-object-label").val("")
	$("#create-object-model").val("")
	$("#create-object-distance").val(100)

	$('#create-object-modal').modal('hide');

	CloseUI()
}

function ManageObjects() {
	$("#manage-objs-list").html("")
	$.post('https://objectspawner/GetPlacedObjects', JSON.stringify({}), function(objects) {
		if (objects.length > 0) {
			$.each(objects, function(id, oData) {
				console.log(id, oData);

				let coords = 'vector3(' + oData.coords.x + ', ' + oData.coords.y + ', ' + oData.coords.z + ')'
				$("#manage-objs-list").append('<tr> <td>' + oData.label + '</td> <td>' + oData.model + '</td> <td>' + coords + '</td> <td>' + oData.uuid + '</td> <td><button type="button" class="btn btn-danger" onclick="DeleteObject(\'' + oData.uuid + '\')"><i class="fas fa-trash-alt"></i></button></td> </tr>')
			})
		}

		$('#main-object-modal').modal('hide');
		$('#manage-object-modal').modal('show')
	});

}

function DeleteObject(uuid) {
	$.post('https://objectspawner/DeleteObject', JSON.stringify({
		uuid: uuid,
	}), function() {
		ManageObjects()
	});
}