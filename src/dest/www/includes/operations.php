<?php 
$op = $_REQUEST['op'];
switch ($op) {
  case "start":
    unset($out);
    exec("/bin/sh /usr/bin/DroboApps.sh start_app ".$app, $out, $rc);
    if ($rc === 0) {
      $opstatus = "okstart";
    } else {
      $opstatus = "nokstart";
    }
    break;
  case "stop":
    unset($out);
    exec("/bin/sh /usr/bin/DroboApps.sh stop_app ".$app, $out, $rc);
    if ($rc === 0) {
      $opstatus = "okstop";
    } else {
      $opstatus = "nokstop";
    }
    break;
  case "logs":
    $opstatus = "logs";
    break;
  default:
    $opstatus = "noop";
    break;
}

unset($out);
exec("/usr/bin/DroboApps.sh status_app ".$app, $out, $rc);
if (strpos($out[0], "running") !== FALSE) {
  $apprunning = TRUE;
} else {
  $apprunning = FALSE;
}
?>