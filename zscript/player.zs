class BladerPlayer : DoomPlayer
{
	//WHAT UNHOLY POWER DROVE ME TO WRITE THIS

	double sJumpMin; double sJumpFac; double sJumpSpeed; double sJumpCap;
	double momentum;
	double freshStep; // Rises to max when you make a fresh left/right input. Decays over time.
	int slideframes;
	double skateAngle;

	Property StrafeJump : sJumpFac, sJumpMin, sJumpSpeed, sJumpCap;

	void SetSkateAngle(double ang)
	{
		// Sets the player's skateAngle.
		skateAngle = Normalize180(ang);
	}

	default
	{
		BladerPlayer.StrafeJump 14,1,10.0,75;
		Player.StartItem "RollerShotgun";
		Player.StartItem "RollerShells", 12;
		Friction 1.0;
		Player.GruntSpeed 0.0;
		Player.Soundclass "blader";
		Tag "Gun Blader";
	}

	override void MovePlayer ()
	{
		// This is mostly copied from gzdoom player.zs for now.
		let player = self.player;
		UserCmd cmd = player.cmd;

		// [RH] 180-degree turn overrides all other yaws
		if (player.turnticks)
		{
			player.turnticks--;
			Angle += (180. / TURN180_TICKS);
		}
		else
		{
			Angle += cmd.yaw * (360./65536.);
		}

		player.onground = (pos.z <= floorz) || bOnMobj || bMBFBouncer || (player.cheats & CF_NOCLIP2);

		bool isStrafeTurning = (cmd.sidemove < 0 && cmd.yaw > 0) || (cmd.sidemove > 0 && cmd.yaw < 0);

		if((cmd.buttons & BT_MOVELEFT && !(player.oldbuttons & BT_MOVELEFT)) || (cmd.buttons & BT_MOVERIGHT && !(player.oldbuttons & BT_MOVERIGHT)))
		{
			//Freshen up our step.
			freshStep = 1.0;
			A_StartSound("player/kick",6);
		}
		else
		{
			freshStep = max(0,freshStep - min(1./(vel.length()),1./70.));
			A_StartSound("player/stride",5,CHANF_NOSTOP);
		}

		if(player.onground) 
		{ 
			A_SoundVolume(5,vel.length()*freshStep); 
			A_SoundVolume(6,freshStep); 
		} 
		else 
		{ 
			A_SoundVolume(5,0); 
			A_SoundVolume(6,0); 
		}

		if(player.onground && abs(cmd.yaw)>0.1 && isStrafeTurning)
		{
			SetSkateAngle(angle); // Only update our direction of travel when we're on the ground and strafeturning.
			double ang = cmd.yaw*(360./65536.);
			Vector2 move = (cmd.forwardmove,cmd.sidemove/2.).unit();
			double moveAng = atan2(-move.y,move.x);
			double amt = max(abs(ang),sJumpMin);
			double fvel = freshStep * (cos(sJumpFac/amt)*sJumpSpeed);

			if(fvel < 0)
			{
				fvel = -fvel;
			}

			momentum += fvel;
		}
		momentum = max(0,momentum-max(0.1,momentum*0.1));
		if(momentum > sJumpCap)
		{
			double cappedvel = momentum - sJumpCap;
			momentum = sJumpCap + cappedvel * 0.5;
		}

		if(player.onground) {Thrust(momentum/35.,skateAngle);} 

		if (!(player.cheats & CF_PREDICTING) && (cmd.forwardmove != 0 || cmd.sidemove != 0))
		{
			PlayRunning ();
		}

		if (player.cheats & CF_REVERTPLEASE)
		{
			player.cheats &= ~CF_REVERTPLEASE;
			player.camera = player.mo;
		}

		// Slideframes ticks down whenever you're NOT holding crouch, or when you're in the air. It's there to make the boost of speed happen at the start of a slide, not all the time.
		if(!player.onground || !(player.cmd.buttons & BT_CROUCH)) { slideframes = max(slideframes-1,0); }
		// TODO: Powerslide.
	}
}