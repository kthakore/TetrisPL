use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'SDL::Tutorial::Tetris',
      license         => 'perl',
      requires 	=>
      {
	      'SDL' => '2.2.2.15'
      }
    )->create_build_script;
