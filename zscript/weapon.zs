class RollerWeapon : Weapon
{
	// Base class for weapons. Handles schmovement.	

	action void A_Recoil(double force)
	{
		let plr = BladerPlayer(invoker.owner);
		plr.SetSkateAngle(plr.angle-180);
		plr.momentum += force;
		plr.Thrust(force*cos(plr.pitch),plr.angle-180);
		plr.vel.z = force*sin(plr.pitch);
	}
}