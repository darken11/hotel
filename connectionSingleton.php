
<?php
class ConnectionSingleton
{
	/* Connexion à une base de données ODBC en invoquant un driver */
	var $dsn = 'mysql:dbname=hotel;host=127.0.0.1';
	var $user = 'root';
	var $password = '';
	var $dbh;
	private static $instance=null;
	private function __construct()
	{   
	    
		try {
  		$this->dbh = new PDO($this->dsn, $this->user, $this->password);

			} 	catch (PDOException $e) {
  				echo 'Echec de la connexion : ' . $e->getMessage();
										}
	}
	 public static function getInstance() 
	 {
		if(is_null(self::$instance)) 
		{
		self::$instance = new ConnectionSingleton();
}
		return self::$instance;
}
}
?>

