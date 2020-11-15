function notify(message) {
    $('.toast-body').html(message);
    $('.toast').toast('show');
}

$(document).ready(function () {
    $('.toast').toast({ delay:3000 });

    $('table .btn-outline-info').click(function() {
        $('#option').val('change');
        $('#guide').html('Change password of user ' + $(this).attr('data-user') + ':');
        $('#makeSupervisor').parent().hide();
        $('#username')
            .val($(this).attr('data-user'))
            .hide();
        $('#create').hide();
        $('#change')
            .removeAttr('hidden')
            .show();
        $('#cancel')
            .removeAttr('hidden')
            .show();
        $('#password').focus(); 
    });

    $('#cancel').click(function() {
        $('#guide').html('Create new user:');
        $('#makeSupervisor').parent().show();
        $('#option').val($('#makeSupervisor').prop('checked') ? 'addsup' : 'add');
        $('#create').show();
        $('#change').hide();
        $('#cancel').hide();
        $('#username')
            .val('')
            .show()
            .focus();
    });
   
    $('#makeSupervisor').change(function () {
        $('#option').val($(this).prop('checked') ? 'addsup' : 'add');
    });
});
