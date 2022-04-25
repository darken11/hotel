<?php
session_start();
include('header.html');
?>
<div class="row-fluid">
	<div class="span4  offset1">
<?php
	
	spl_autoload_register();
	$employeManager=new EmployeManager();
	$result=$employeManager->getByLogin($_POST['login'],$_POST['password']);
	if($result[0]==1)
	{
		$_SESSION['login']="admin";
		header('Location: index.php');
	}
	else
	{
		include('login.html');
	}
?>