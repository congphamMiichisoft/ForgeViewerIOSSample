function initialize (options) {

  return new Promise(function(resolve, reject) {

    Autodesk.Viewing.Initializer (options,
      function () {

        resolve ()

      }, function(error){

        reject (error)
      })
  })
}
function loadDocument (urn) {

  return new Promise(function(resolve, reject) {

    var paramUrn = !urn.startsWith("urn:")
      ? "urn:" + urn
      : urn

    Autodesk.Viewing.Document.load(paramUrn,
      function(doc) {

        resolve (doc)

      }, function (error) {

        reject (error)
      })
  })
}
function getViewableItems (doc, roles) {

  var rootItem = doc.getRootItem()

  var items = []

  var roleArray = roles
    ? (Array.isArray(roles) ? roles : [roles])
    : []

  roleArray.forEach(function(role) {

    var subItems =
      Autodesk.Viewing.Document.getSubItemsWithProperties(
        rootItem, { type: "geometry", role: role }, true)

    items = items.concat(subItems)
  })

  return items
}
function getQueryParam (name, url) {

  if (!url) url = window.location.href;
  name = name.replace(/[\[\]]/g, "\\$&");
  var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
    results = regex.exec(url);
  if (!results) return null;
  if (!results[2]) return '';
  return decodeURIComponent(results[2].replace(/\+/g, " "));
}
initialize({

  //acccessToken: getQueryParam("acccessToken"),
  env: "Local"

}).then(function() {
  var viewerDiv = document.getElementById("viewer")

  var viewer = new Autodesk.Viewing.Private.GuiViewer3D(viewerDiv)
  
  viewer.start()

  viewer.loadModel('./www/models/3D/0.svf')
})
