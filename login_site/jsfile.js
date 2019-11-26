function check(document)
{
    if(   document.getElementById("name").value == "workshop"
       && document.getElementById("pass").value == "workshop" )
    {
       alert( "validation succeeded" );
        //location.href="run.html";
    }
    else
    {
        alert( "validation failed" );
        //location.href="fail.html";
    }
return true;
}
