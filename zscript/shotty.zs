class RollerShotgun : RollerWeapon replaces Pistol
{
	// A shotgun.

	default
	{
		Weapon.AmmoType1 "RollerShells";
		Weapon.AmmoUse1 1;
		Weapon.SlotNumber 2;
		Weapon.AmmoGive 12;
	}	

	action void A_FireShotty()
	{
		A_GunFlash();
		A_StartSound("weapons/shotgf");
		A_FireProjectile("ShottyPellet",0,true);
		for(int i = 0; i<360; i+=(360/4))
		{
			A_FireProjectile("ShottyPellet",sin(i),false,pitch:cos(i));
		}

		A_Recoil(20);
	}

	states
	{
		Select:
			SHTG A 1 A_Raise(30);
			Loop;
		Deselect:
			SHTG A 1 A_Lower(30);
			Loop;
		Ready:
			SHTG A 1 A_WeaponReady();
			Loop;
		Fire:
			SHTG A 3 A_FireShotty();
			SHTG BCD 4;
			SHTG CB 5;
			Goto Ready;
		Flash:
			SHTF A 2 Bright;
			SHTF B 1 Bright;
			Stop;
	}
}

class RollerShells : Ammo replaces Clip
{
	// Shells!
	default
	{
		Inventory.Amount 3;
		Inventory.MaxAmount 45;
	}

	states
	{
		Spawn:
			SHEL A -1;
			Stop;
	}
}

class ShottyPellet : FastProjectile
{
	// A single pellet.

	default
	{
		Speed 50;
		DamageFunction 5;
	}

	states
	{
		Spawn:
			PUFF A 1;
			PUFF A 1 Bright;
			Loop;
		Death:
			PUFF BCD 2;
			Stop;
	}
}