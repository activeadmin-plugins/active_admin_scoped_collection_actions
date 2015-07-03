function aa_scoped_collection_actions_post_to_url(path, params, method)
{
    method = method || "post"; // Set method to post by default, if not specified.

    // The rest of this code assumes you are not using a library.
    // It can be made less wordy if you use one.
    var form = document.createElement("form");
    form.setAttribute("method", method);
    form.setAttribute("action", path);

    function create_hidden_fields(name, value) {
        var hf = document.createElement("input");
        hf.setAttribute("type", "hidden");
        hf.setAttribute("name", name);
        hf.setAttribute("value", value);
        return hf;
    }

    for(var key in params) {
        if(typeof(params[key]) == 'object') {
            var params2 = params[key];
            for(var key2 in params2) {
                form.appendChild(create_hidden_fields('changes[' + key2 + ']', params2[key2]));
            }
        } else if(params.hasOwnProperty(key)) {
            form.appendChild(create_hidden_fields(key, params[key]));
        }
    }

    document.body.appendChild(form);
    form.submit();
}