/*
	HOW DO I LOG RUNTIMES?
	Firstly, start dreamdeamon if it isn't already running. Then select "world>Log Session" (or press the F3 key)
	navigate the popup window to the data/logs/runtime/ folder from where your vgstation13.dmb is located.
	(you may have to make this folder yourself)

	OPTIONAL: 	you can select the little checkbox down the bottom to make dreamdeamon save the log everytime you
				start a world. Just remember to repeat these steps with a new name when you update to a new revision!

	Save it with the name of the revision your server uses (e.g. r3459.txt).
	Game Masters will now be able to grant access any runtime logs you have archived this way!
	This will allow us to gather information on bugs across multiple servers and make maintaining the TG
	codebase for the entire /TG/station commuity a TONNE easier :3 Thanks for your help!
*/


//This proc allows Game Masters to grant a client access to the .getruntimelog verb
//Permissions expire at the end of each round.
//Runtimes can be used to meta or spot game-crashing exploits so it's advised to only grant coders that
//you trust access. Also, it may be wise to ensure that they are not going to play in the current round.
/client/proc/giveruntimelog()
	set name = ".giveruntimelog"
	set desc = "Give somebody access to any session logfiles saved to the /log/runtime/ folder."
	set category = null

	if(!src.holder)
		src << "<font color='red'>Only Admins may use this command.</font>"
		return

	var/client/target = input(src,"Choose somebody to grant access to the server's runtime logs (permissions expire at the end of each round):","Grant Permissions",null) as null|anything in clients
	if(!istype(target,/client))
		src << "<font color='red'>Error: giveruntimelog(): Client not found.</font>"
		return

	target.verbs |= /client/proc/getruntimelog
	target << "<font color='red'>You have been granted access to runtime logs. Please use them responsibly or risk being banned.</font>"
	return


//This proc allows download of runtime logs saved within the data/logs/ folder by dreamdeamon.
//It works similarly to show-server-log.
/client/proc/getruntimelog()
	set name = ".getruntimelog"
	set desc = "Retrieve any session logfiles saved by dreamdeamon."
	set category = null

	var/path = browse_files("data/logs/runtime/")
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	#ifdef RUNWARNING
	#if DM_VERSION > 506 && DM_VERSION < 508
		#warn Run is deprecated and disabled for some fucking reason in 507.1275/6, if you have a version that doesn't have run() disabled then comment out #define RUNWARNING in setup.dm
	src << ftp( file(path) )
	#else
	src << run( file(path) )
	#endif
	#else
	src << run( file(path) )
	#endif
	src << "Attempting to send file, this may take a fair few minutes if the file is very large."
	return


//This proc allows download of past server logs saved within the data/logs/ folder.
//It works similarly to show-server-log.
/client/proc/getserverlog()
	set name = ".getserverlog"
	set desc = "Fetch logfiles from data/logs"
	set category = null

	var/path = browse_files("data/logs/")
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	#ifdef RUNWARNING
	#if DM_VERSION > 506 && DM_VERSION < 508
		#warn Run is deprecated and disabled for some fucking reason in 507.1275/6, if you have a version that doesn't have run() disabled then comment out #define RUNWARNING in setup.dm
	src << ftp( file(path) )
	#else
	src << run( file(path) )
	#endif
	#else
	src << run( file(path) )
	#endif
	src << "Attempting to send file, this may take a fair few minutes if the file is very large."
	return


//Other log stuff put here for the sake of organisation

//Shows today's server log
/datum/admins/proc/view_txt_log()
	set category = "Admin"
	set name = "Show Server Log"
	set desc = "Shows today's server log."

	var/path = "data/logs/[time2text(world.realtime,"YYYY/MM-Month/DD-Day")].log"
	if( fexists(path) )
	#ifdef RUNWARNING
		#if DM_VERSION > 506 && DM_VERSION < 508
			#warn Run is deprecated and disabled for some fucking reason in 507.1275/6, if you have a version that doesn't have run() disabled then comment out #define RUNWARNING in setup.dm
		src << ftp( file(path) )
		#else
		src << run( file(path) )
		#endif
		#else
		src << run( file(path) )
		#endif
	else
		src << "<font color='red'>Error: view_txt_log(): File not found/Invalid path([path]).</font>"
		return
	feedback_add_details("admin_verb","VTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

//Shows today's attack log
/datum/admins/proc/view_atk_log()
	set category = "Admin"
	set name = "Show Server Attack Log"
	set desc = "Shows today's server attack log."

	var/path = "data/logs/[time2text(world.realtime,"YYYY/MM-Month/DD-Day")] Attack.log"
	if( fexists(path) )
		#ifdef RUNWARNING
		#if DM_VERSION > 506 && DM_VERSION < 508
			#warn Run is deprecated and disabled for some fucking reason in 507.1275/6, if you have a version that doesn't have run() disabled then comment out #define RUNWARNING in setup.dm
		src << ftp( file(path) )
		#else
		src << run( file(path) )
		#endif
		#else
		src << run( file(path) )
		#endif
	else
		src << "<font color='red'>Error: view_atk_log(): File not found/Invalid path([path]).</font>"
		return
	feedback_add_details("admin_verb","SSAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/datum/admins/proc/view_mob_attack_log(var/mob/M as mob)
	set category	= "Admin"
	set name		= "Show mob's attack logs"
	set desc			= "Shows the (formatted) attack log of a mob in a HTML window."

	if(!istype(M))
		usr << "That's not a valid mob!"
		return

	var/datum/browser/clean/popup = new (usr, "\ref[M]_admin_log_viewer", "Attack logs of [M]", 300, 300)
	popup.set_content(list2text(M.attack_log, "<br/>"))
	popup.open()

	feedback_add_details("admin_verb","VMAL")
