<?php

namespace tgui\Controllers\APISettings;

use tgui\PHPMailer\EmailEngine;
use tgui\Models\APIPWPolicy;
use tgui\Models\APISMTP;
use tgui\Models\APISettings;
use tgui\Controllers\Controller;
use Respect\Validation\Validator as v;
use tgui\Services\CMDRun\CMDRun as CMDRun;
// use tgui\Controllers\APISettings\HA;

class APISettingsCtrl extends Controller
{
####PASSWORD POLICY#####
  public function getPasswdPolicy($req,$res)
	{
		//INITIAL CODE////START//
		$data=array();
		$data=$this->initialData([
			'type' => 'get',
			'object' => 'api settings',
			'action' => 'info',
		]);
		#check error#
		if ($_SESSION['error']['status']){
			$data['error']=$_SESSION['error'];
			return $res -> withStatus(401) -> write(json_encode($data));
		}
		//INITIAL CODE////END//
		//CHECK ACCESS TO THAT FUNCTION//START//
		if(!$this->checkAccess(1, true))
		{
			return $res -> withStatus(403) -> write(json_encode($data));
		}
		//CHECK ACCESS TO THAT FUNCTION//END//

    $data['policy'] = APIPWPolicy::select()->find(1);

    return $res -> withStatus(200) -> write(json_encode($data));
  }

  public function postPasswdPolicy($req,$res)
	{
		//INITIAL CODE////START//
		$data=array();
		$data=$this->initialData([
			'type' => 'post',
			'object' => 'api settings',
			'action' => 'change',
		]);
		#check error#
		if ($_SESSION['error']['status']){
			$data['error']=$_SESSION['error'];
			return $res -> withStatus(401) -> write(json_encode($data));
		}
		//INITIAL CODE////END//
    //CHECK SHOULD I STOP THIS?//START//
    if( $this->shouldIStopThis() )
    {
      $data['error'] = $this->shouldIStopThis();
      return $res -> withStatus(400) -> write(json_encode($data));
    }
    //CHECK SHOULD I STOP THIS?//END//
		//CHECK ACCESS TO THAT FUNCTION//START//
		if(!$this->checkAccess(1))
		{
			return $res -> withStatus(403) -> write(json_encode($data));
		}
		//CHECK ACCESS TO THAT FUNCTION//END//

    $validation = $this->validator->validate($req, [
      'api_pw_length' => v::when( v::nullType() , v::alwaysValid(), v::numeric()->min(4)->setName('API Password length')),
      'tac_pw_length' => v::when( v::nullType() , v::alwaysValid(), v::numeric()->min(4)->setName('Tacacs Password length')),
      'api_pw_uppercase' => v::when( v::nullType() , v::alwaysValid(), v::numeric()->min(0)->max(1)->setName('API Uppercase Characters')),
      'api_pw_lowercase' => v::when( v::nullType() , v::alwaysValid(), v::numeric()->min(0)->max(1)->setName('API Lowcase Characters')),
      'api_pw_numbers' => v::when( v::nullType() , v::alwaysValid(), v::numeric()->min(0)->max(1)->setName('API Numbers Characters')),
      'api_pw_special' => v::when( v::nullType() , v::alwaysValid(), v::numeric()->min(0)->max(1)->setName('API Special Characters')),
      'tac_pw_uppercase' => v::when( v::nullType() , v::alwaysValid(), v::numeric()->min(0)->max(1)->setName('TACACS Uppercase Characters')),
      'tac_pw_lowercase' => v::when( v::nullType() , v::alwaysValid(), v::numeric()->min(0)->max(1)->setName('TACACS Lowcase Characters')),
      'tac_pw_numbers' => v::when( v::nullType() , v::alwaysValid(), v::numeric()->min(0)->max(1)->setName('TACACS Numbers Characters')),
      'tac_pw_special' => v::when( v::nullType() , v::alwaysValid(), v::numeric()->min(0)->max(1)->setName('TACACS Special Characters')),
    ]);

    if ($validation->failed()){
      $data['error']['status']=true;
      $data['error']['validation']=$validation->error_messages;
      return $res -> withStatus(200) -> write(json_encode($data));
    }

    $allParams = $req->getParams();

		unset($allParams['id']);

    $data['result'] = APIPWPolicy::where('id', 1)->update($allParams);

    return $res -> withStatus(200) -> write(json_encode($data));
  }
####PASSWORD POLICY#####End
####SMTP SETTINGS######
public function getSmtp($req,$res)
{
  //INITIAL CODE////START//
  $data=array();
  $data=$this->initialData([
    'type' => 'get',
    'object' => 'api settings',
    'action' => 'info',
  ]);
  #check error#
  if ($_SESSION['error']['status']){
    $data['error']=$_SESSION['error'];
    return $res -> withStatus(401) -> write(json_encode($data));
  }
  //INITIAL CODE////END//
  //CHECK ACCESS TO THAT FUNCTION//START//
  if(!$this->checkAccess(1, true))
  {
    return $res -> withStatus(403) -> write(json_encode($data));
  }
  //CHECK ACCESS TO THAT FUNCTION//END//

  $data['smtp'] = APISMTP::select()->find(1);

  $data['smtp']['smtp_password'] = $this->generateRandomString( strlen($data['smtp']['smtp_password']) );

  return $res -> withStatus(200) -> write(json_encode($data));
}

public function postSmtp($req,$res)
{
  //INITIAL CODE////START//
  $data=array();
  $data=$this->initialData([
    'type' => 'post',
    'object' => 'api settings',
    'action' => 'change',
  ]);
  #check error#
  if ($_SESSION['error']['status']){
    $data['error']=$_SESSION['error'];
    return $res -> withStatus(401) -> write(json_encode($data));
  }
  //INITIAL CODE////END//
  //CHECK SHOULD I STOP THIS?//START//
  if( $this->shouldIStopThis() )
  {
    $data['error'] = $this->shouldIStopThis();
    return $res -> withStatus(400) -> write(json_encode($data));
  }
  //CHECK SHOULD I STOP THIS?//END//
  //CHECK ACCESS TO THAT FUNCTION//START//
  if(!$this->checkAccess(1))
  {
    return $res -> withStatus(403) -> write(json_encode($data));
  }
  //CHECK ACCESS TO THAT FUNCTION//END//

  $validation = $this->validator->validate($req, [
    'smtp_port' => v::when( v::nullType() , v::alwaysValid(), v::numeric()->between(1, 64000)->setName('SMTP Port')),
    'smtp_from' => v::when( v::nullType() , v::alwaysValid(), v::email()->setName('From Address')),
  ]);

  if ($validation->failed()){
    $data['error']['status']=true;
    $data['error']['validation']=$validation->error_messages;
    return $res -> withStatus(200) -> write(json_encode($data));
  }

  $allParams = $req->getParams();

  unset($allParams['id']);

  $data['result'] = APISMTP::where('id', 1)->update($allParams);

  return $res -> withStatus(200) -> write(json_encode($data));
}

public function postSmtpTest($req,$res)
{
  //INITIAL CODE////START//
  $data=array();
  $data=$this->initialData([
    'type' => 'post',
    'object' => 'smtp',
    'action' => 'test',
  ]);
  #check error#
  if ($_SESSION['error']['status']){
    $data['error']=$_SESSION['error'];
    return $res -> withStatus(401) -> write(json_encode($data));
  }
  //INITIAL CODE////END//
  //CHECK ACCESS TO THAT FUNCTION//START//
  if(!$this->checkAccess(1))
  {
    return $res -> withStatus(403) -> write(json_encode($data));
  }
  //CHECK ACCESS TO THAT FUNCTION//END//

  $validation = $this->validator->validate($req, [
    'smtp_test_email' => v::when( v::alwaysValid(), v::email()->notEmpty()->setName('Email') ),
  ]);

  if ($validation->failed()){
    $data['error']['status']=true;
    $data['error']['validation']=$validation->error_messages;
    return $res -> withStatus(200) -> write(json_encode($data));
  }

  $allParams = $req->getParams();

  $email = new EmailEngine(APISMTP::select()->find(1));
  $email->mail->addAddress($allParams['smtp_test_email']);
  $email->setTemplate();
  $data['result'] = $email->send();

  return $res -> withStatus(200) -> write(json_encode($data));
}
####SMTP SETTINGS######End
############
####TIME####
public static function getTimeTimezoneName($params = ['id' => 0])
{
  if($params['id'] == 0 ) return trim( shell_exec("timedatectl | grep 'Time zone:' | awk '{ print $3 }'"));
  $id = preg_replace('/[^0-9]/', '', $params['id']);
  return trim( shell_exec("timedatectl list-timezones | nl | sed '".$id."!d'" ) );
}

public function getTimeTimezones($req,$res)
{
  //INITIAL CODE////START//
  $data=array();
  $data=$this->initialData([
    'type' => 'post',
    'object' => 'time',
    'action' => 'list',
  ]);
  #check error#
  if ($_SESSION['error']['status']){
    $data['error']=$_SESSION['error'];
    return $res -> withStatus(401) -> write(json_encode($data));
  }
  //INITIAL CODE////END//
  //CHECK ACCESS TO THAT FUNCTION//START//
  if(!$this->checkAccess(1, true))
  {
    return $res -> withStatus(403) -> write(json_encode($data));
  }
  //CHECK ACCESS TO THAT FUNCTION//END//
  $byId = $req->getParam('byId');

  if ( !empty($byId) ){
    $tempData = self::getTimeTimezoneName(['id'=>$byId]);

    $tempData = ( empty($tempData) ) ?  $byId . ' Error Appeared' : $tempData;
    $data['item'] = array();
    $tempTimezone = preg_split('/\s+/', trim( $tempData ) );
    $data['item'] = [ 'id' => $tempTimezone[0], 'text' =>$tempTimezone[1] ];

    return $res -> withStatus(200) -> write(json_encode($data));
  }

  $search = preg_replace('/[^a-zA-Z0-9]/', '', $req->getParam('search'));
  $page = $req->getParam('page');
  $take = 10 * $page;
  $offset = (10 * ($page - 1)) + 1;

  // $tempData = trim( shell_exec('timedatectl list-timezones | nl '.( (empty($search) ? '': '| grep -i '.$search ) ) .' | sed -n "'.$offset.','.$take.'p" ' ) );
  $tempData = CMDRun::init(['version'=>2])->setCmd('timedatectl')->setAttr('list-timezones')->setPipe()->setCmd('nl');
  $tempData = ( empty($search) ) ? $tempData : $tempData->setPipe()->setCmd('grep')->setAttr(['-i',$search]);
  $data['test2'] = $tempData->get();
  $tempData = explode(PHP_EOL, $tempData->get());
  $tempData = ( empty($tempData[0]) ) ? [] : $tempData;
  // timedatectl list-timezones |  sed '30!d'
  // $data['test3'] = 'timedatectl list-timezones '.( (empty($search) ? '': '| grep '.$search ) ) .' | sed -n "'.$offset.','.$take.'p" ' ;
	$data['pagination'] = (!$tempData OR count($tempData) < 10) ? ['more' => false] : [ 'more' => true];
  $data['results'] = array();
  for ($i=0; $i < count($tempData); $i++) {
    $tempTimezone = preg_split('/\s+/', trim($tempData[$i]) );
    $timezone = [ 'id' => $tempTimezone[0], 'text' =>$tempTimezone[1] ];
    array_push($data['results'],$timezone);
  }

  return $res -> withStatus(200) -> write(json_encode($data));
}

public function getTimeSettings($req,$res)
{
  //INITIAL CODE////START//
  $data=array();
  $data=$this->initialData([
    'type' => 'get',
    'object' => 'time',
    'action' => 'settings',
  ]);
  #check error#
  if ($_SESSION['error']['status']){
    $data['error']=$_SESSION['error'];
    return $res -> withStatus(401) -> write(json_encode($data));
  }
  //INITIAL CODE////END//

  //CHECK ACCESS TO THAT FUNCTION//START//
  if(!$this->checkAccess(1, true))
  {
    return $res -> withStatus(403) -> write(json_encode($data));
  }
  //CHECK ACCESS TO THAT FUNCTION//END//
  $data['time'] = APISettings::select(['timezone', 'ntp_list'])->find(1);
  $timezone = preg_split('/\s+/', self::getTimeTimezoneName(['id' => $data['time']->timezone]) );
  $data['time']->timezone = [[ 'id' => $timezone[0], 'text' =>$timezone[1] ]];

  return $res -> withStatus(200) -> write(json_encode($data));
}
public static function applyTimeSettings( $allParams = [] )
{
  if ( !empty($allParams['timezone']) ){
    $timezoneName = trim( shell_exec( "timedatectl list-timezones |  sed '".$allParams['timezone']."!d'" ) );
    $data['result_timezone'] = trim( shell_exec( 'sudo '. TAC_ROOT_PATH . "/main.sh ntp timezone ".$timezoneName ) );
  }
  // Verify if NTP or NTPSEC
  $ntpsecStatus = shell_exec('systemctl is-active ntpsec.service');
  $ntpsecStatus = trim($ntpsecStatus);
  // $logFile = TAC_ROOT_PATH . "/temp/ntp_service.log";
  // error_log("NTP SEC Status: $ntpsecStatus\n", 3, $logFile);
  // error_log("NTP Service Status: $ntpService\n", 3, $logFile);
  $templateNtp = TAC_ROOT_PATH . "/templates/ntp.conf";
  $templateNtpsec = TAC_ROOT_PATH . "/templates/ntpsec.conf";
  if ($ntpsecStatus === 'active') {
    $ntpService = "ntpsec";
    $templateNTPFile = $templateNtpsec;
  } else {
      $ntpService = "ntp";
      $templateNTPFile = $templateNtp;
  }
  // just in case template files missing
  $templateNTPContent = file_get_contents($templateNTPFile);
  if ($templateNTPContent === false) {
    if ($ntpService === "ntpsec") {
        $templateNTPContent = "# TACACS\ndriftfile /var/lib/ntpsec/ntp.drift\nleapfile /usr/share/zoneinfo/leap-seconds.list\ntos maxclock 11\ntos minclock 4 minsane 3\nrestrict default kod nomodify nopeer noquery limited\nrestrict 127.0.0.1\nrestrict ::1";
    } else {
      $templateNTPContent = "# TACACS\ndriftfile /var/lib/ntp/ntp.drift\nleapfile /usr/share/zoneinfo/leap-seconds.list\nrestrict default kod nomodify nopeer noquery limited\nrestrict 127.0.0.1\nrestrict ::1";
    }
  }

  if ( !empty($allParams['ntp_list']) ){
    // open overwrite temp file
    $ntpfile = fopen(TAC_ROOT_PATH ."/temp/ntp.conf", "w");
    // write template content we got above
    fwrite($ntpfile, $templateNTPContent);
    $txt = "\n";
    // make the list from GUI
    $ntp_list = explode(";", $allParams['ntp_list']);
    for ($i=0; $i < count($ntp_list); $i++) {
      if ( empty(trim($ntp_list[$i])) ) continue;
      $txt .= 'server ' . trim($ntp_list[$i]) . "\n";
    }
    // write and close
    fwrite($ntpfile, $txt);
    fclose($ntpfile);
    return true;
  } else {
    return true;
  }
  return false;
}
public function postTimeSettings($req,$res)
{
  //INITIAL CODE////START//
  $data=array();
  $data=$this->initialData([
    'type' => 'post',
    'object' => 'time',
    'action' => 'settings',
  ]);
  #check error#
  if ($_SESSION['error']['status']){
    $data['error']=$_SESSION['error'];
    return $res -> withStatus(401) -> write(json_encode($data));
  }
  //INITIAL CODE////END//
  //CHECK SHOULD I STOP THIS?//START//
  if( $this->shouldIStopThis() )
  {
    $data['error'] = $this->shouldIStopThis();
    return $res -> withStatus(400) -> write(json_encode($data));
  }
  //CHECK SHOULD I STOP THIS?//END//
  //CHECK ACCESS TO THAT FUNCTION//START//
  if(!$this->checkAccess(1))
  {
    return $res -> withStatus(403) -> write(json_encode($data));
  }
  //CHECK ACCESS TO THAT FUNCTION//END//
  $validation = $this->validator->validate($req, [
    'timezone' => v::when( v::nullType(), v::alwaysValid(), v::numeric()->notEmpty()->setName('Timezone') ),
  ]);

  if ($validation->failed()){
    $data['error']['status']=true;
    $data['error']['validation']=$validation->error_messages;
    return $res -> withStatus(200) -> write(json_encode($data));
  }

  $allParams = $req->getParams();

  if (self::applyTimeSettings($allParams)) {
    $data['result_ntp'] = trim( shell_exec( 'sudo '. TAC_ROOT_PATH . "/main.sh ntp get-config ") );
    $data['result'] = APISettings::where('id', 1)->update($allParams);
    sleep(1);
    return $res -> withStatus(200) -> write(json_encode($data));
  }

  return $res -> withStatus(400) -> write(json_encode($data));
}

public function getTimeStatus($req,$res)
{
  //INITIAL CODE////START//
  $data=array();
  $data=$this->initialData([
    'type' => 'get',
    'object' => 'time',
    'action' => 'status',
  ]);
  #check error#
  if ($_SESSION['error']['status']){
    $data['error']=$_SESSION['error'];
    return $res -> withStatus(401) -> write(json_encode($data));
  }
  //INITIAL CODE////END//
  //CHECK ACCESS TO THAT FUNCTION//START//
  if(!$this->checkAccess(1, true))
  {
    return $res -> withStatus(403) -> write(json_encode($data));
  }
  //CHECK ACCESS TO THAT FUNCTION//END//
  $output = "command timedatectl :\n";
  $output .= shell_exec('timedatectl');
  $output .= "\n";
  $output .= "command ntpq -p :\n";
  $output .= shell_exec('ntpq -p');

  $data['output'] = $output;

  return $res -> withStatus(200) -> write(json_encode($data));
}
####TIME SETTINGS######End
#########################
####NETWORK SETTINGS######
public function getInterfaceSettings($req,$res)
{
  //INITIAL CODE////START//
  $data=array();
  $data=$this->initialData([
    'type' => 'get',
    'object' => 'interface',
    'action' => 'info',
  ]);
  #check error#
  if ($_SESSION['error']['status']){
    $data['error']=$_SESSION['error'];
    return $res -> withStatus(401) -> write(json_encode($data));
  }
  //INITIAL CODE////END//
  //CHECK ACCESS TO THAT FUNCTION//START//
  if(!$this->checkAccess(1, true))
  {
    return $res -> withStatus(403) -> write(json_encode($data));
  }
  //CHECK ACCESS TO THAT FUNCTION//END//

  $allParams = $req->getParams();

  $cmd = CMDRun::init()->setSudo()->setCmd(TAC_ROOT_PATH . '/interfaces.py')->setAttr('-l');
  // file_put_contents('/path/to/your/debug_file.txt', "Constructed Command: " . $cmd->showCmd() . PHP_EOL, FILE_APPEND);
  $output = $cmd->get();
  $data['list'] = explode(PHP_EOL, $output);

  if ($data['list'][0] == 'lo') unset($data['list'][0]);
  $data['list'] = array_values($data['list']);
  // FIX FOR INTERFACE LISTING
  if (empty($data['list'])) {
    // Handle the case where no interfaces are found
    return $res->withStatus(400)->write(json_encode(['error' => 'No interfaces found']));
  }

  $inter = (empty($allParams['interface'])) ? $data['list'][0] : $allParams['interface'];

  // Verify if the selected interface is valid
  if (!in_array($inter, $data['list'])) {
      return $res->withStatus(400)->write(json_encode(['error' => 'Invalid interface selected']));
  }

  // if ( empty($allParams['interface']) ){
  //   return $res -> withStatus(400) -> write(json_encode($data));
  // }

  $cmd = CMDRun::init()->setSudo()->setCmd(TAC_ROOT_PATH . '/interfaces.py')->setAttr(['-i', $inter, '--netplan']);
  $data['cmd'] = $cmd->showCmd();
  // $interfaceSettings = trim( shell_exec(TAC_ROOT_PATH . '/interfaces.sh get '.$inter.' skip 3') );
  $interfaceSettings = $cmd->get();

  $settingsLine=explode(PHP_EOL, $interfaceSettings);

  $data['interface'] = [
    'network_address' => '',
    'network_address6' => '',
    'network_mask' => '',
    'network_gateway' => '',
    'network_gateway6' => '',
    'network_dns1' => '',
    'network_dns2' => '',
    // 'network_more' => ''
  ];

  for ($i=0; $i < count($settingsLine); $i++) {
    $parameters = preg_split('/:\s+/', $settingsLine[$i]);
    switch ($parameters[0]) {
      case 'ip address':
        list($data['interface']['network_address'], $data['interface']['network_mask'] ) = explode('/', $parameters[1]);
        //$data['interface']['network_address'] = $parameters[1];
        break;
      case 'ip address6':
        $data['interface']['network_address6'] = $parameters[1];
        //$data['interface']['network_address'] = $parameters[1];
        break;
      case 'defaultgw':
        $data['interface']['network_gateway'] = $parameters[1];
        break;
      case 'defaultgw6':
        $data['interface']['network_gateway6'] = $parameters[1];
        break;
      case 'nameservers':
        list($data['interface']['network_dns1'], $data['interface']['network_dns2']) = explode(' ', $parameters[1]);
        // $data['interface']['network_dns1'] = $parameters[1];
        // if (!empty($parameters[2])) $data['interface']['network_dns2'] = $parameters[2];
        break;
      // default:
      //   $data['interface']['network_more'] .= (!empty($parameters[0])) ? $settingsLine[$i]."\n" : '';
      //   break;
    }
  }

  return $res -> withStatus(200) -> write(json_encode($data));
}

public function postInterfaceSettings($req,$res)
{
  //INITIAL CODE////START//
  $data=array();
  $data=$this->initialData([
    'type' => 'post',
    'object' => 'interface',
    'action' => 'save',
  ]);
  #check error#
  if ($_SESSION['error']['status']){
    $data['error']=$_SESSION['error'];
    return $res -> withStatus(401) -> write(json_encode($data));
  }
  //INITIAL CODE////END//
  //CHECK SHOULD I STOP THIS?//START//
  if( $this->shouldIStopThis() )
  {
    $data['error'] = $this->shouldIStopThis();
    return $res -> withStatus(400) -> write(json_encode($data));
  }
  //CHECK SHOULD I STOP THIS?//END//
  //CHECK ACCESS TO THAT FUNCTION//START//
  if(!$this->checkAccess(1))
  {
    return $res -> withStatus(403) -> write(json_encode($data));
  }
  //CHECK ACCESS TO THAT FUNCTION//END//

  $validation = $this->validator->validate($req, [
    'network_address' => v::when( v::alwaysValid(), v::ip()->notEmpty()->setName('IP Address') ),
    'network_address6' => v::when( v::alwaysValid(), v::oneOf(v::ip('*', FILTER_FLAG_IPV6), v::equals(''))->setName('IP Address') ),
    'network_prefix6' => v::when( v::alwaysValid(), v::numeric()->between(1, 128)->setName('Prefix v6') ),
    'network_mask' => v::when( v::alwaysValid(), v::ip()->notEmpty()->setName('Mask') ),
    'network_gateway' => v::when( v::oneOf(v::nullType(), v::equals('')) , v::alwaysValid(), v::ip()->setName('Gateway')),
    'network_gateway6' => v::when( v::oneOf(v::nullType(), v::equals('')) , v::alwaysValid(), v::ip('*', FILTER_FLAG_IPV6)->setName('Gateway6')),
    'network_dns1' => v::when( v::oneOf(v::nullType(), v::equals('')) ,
        v::alwaysValid(),
        v::oneOf(v::ip(), v::ip('*', FILTER_FLAG_IPV6))->setName('Primary DNS')),
    'network_dns2' => v::when( v::oneOf(v::nullType(), v::equals('')) ,
        v::alwaysValid(),
        v::oneOf(v::ip(), v::ip('*', FILTER_FLAG_IPV6))->setName('Secondary DNS')),
  ]);

  if ($validation->failed()){
    $data['error']['status']=true;
    $data['error']['validation']=$validation->error_messages;
    return $res -> withStatus(200) -> write(json_encode($data));
  }

  $allParams = $req->getParams();
  $attrs = [
    'network','save',
    $allParams['network_interface'],
    $allParams['network_address'],
    $allParams['network_mask']
  ];

  if ( !empty($allParams['network_gateway']) ) {
    $attrs[] = '--gateway';
    $attrs[] = $allParams['network_gateway'];
  }

  if ( !empty($allParams['network_dns1']) ) {
    $content = 'nameserver '. $allParams['network_dns1']."\n";
    $attrs[] = '-nm';
    $attrs[] = $allParams['network_dns1'];
    if ( !empty($allParams['network_dns2']) ) {
      $attrs[] = $allParams['network_dns2'];
      $content .= "nameserver ". $allParams['network_dns2']."\n";
    }
    file_put_contents('/opt/tgui_data/lwresd.config', $content);
  }

  if ( !empty($allParams['network_address6']) ) {
    $attrs[] = '-ipv6';
    $attrs[] = $allParams['network_address6'].'/'.$allParams['network_prefix6'];
    if ( !empty($allParams['network_gateway6']) ) {
      $attrs[] = '--gateway6';
      $attrs[] = $allParams['network_gateway6'];
    }
  }

  $cmd = CMDRun::init()->setSudo()->setCmd(MAINSCRIPT)->
    setAttr($attrs)->setAttr('-y');
  $data['cmd'] = $cmd->showCmd();
  $data['result'] = $cmd->get();
  return $res -> withStatus(200) -> write(json_encode($data));
}

public function getInterfaceList($req,$res)
{
  //INITIAL CODE////START//
  $data=array();
  $data=$this->initialData([
    'type' => 'get',
    'object' => 'interface',
    'action' => 'list',
  ]);
  #check error#
  if ($_SESSION['error']['status']){
    $data['error']=$_SESSION['error'];
    return $res -> withStatus(401) -> write(json_encode($data));
  }
  //INITIAL CODE////END//
  //CHECK ACCESS TO THAT FUNCTION//START//
  if(!$this->checkAccess(1, true))
  {
    return $res -> withStatus(403) -> write(json_encode($data));
  }
  //CHECK ACCESS TO THAT FUNCTION//END//

  $cmd = CMDRun::init()->setSudo()->setCmd(TAC_ROOT_PATH . '/interfaces.py')->setAttr('-l');
  if ( $req->getParam('ip') == 1 ) $cmd->setAttr('--ip');
  $output = trim( shell_exec(TAC_ROOT_PATH . '/interfaces.sh list '. $ip) );
  $output = $cmd->get();
  $data['cmd'] = $cmd->showCmd();
  $data['list'] = explode(PHP_EOL, $output);
  $key = array_search('lo', array_column($data['list'], 0)); // Adjust as needed
  if ($key !== false) unset($data['list'][$key]);
  $data['list'] = array_values($data['list']);  // Reindex the list
  return $res -> withStatus(200) -> write(json_encode($data));
}
}
