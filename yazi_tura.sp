#include <sourcemod>
#include <store>
#include <multicolors>
#include <sdktools>
#include <sdktools_sound>
#include <emitsoundany>

int rastgele;
bool lotoacik;
int creditsToGamble[MAXPLAYERS + 1];
bool playerIsReady[MAXPLAYERS + 1];
new yazi = 0;
new tura = 0;

public Plugin myinfo =
{
	name = "[CSGO] Yazı Tura",
	author = "Vortéx!",
	description = "Yazı Tura eklentisidir.",
	version = "1.0",
	url = "www.turkmodders.com"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_coinflip", LOTTO);
	RegConsoleCmd("sm_flip", LOTTO);
	RegConsoleCmd("sm_yazitura", LOTTO);
	//RegConsoleCmd("sm_debugyz", yz);
}

public void OnMapStart()
{
	PrecacheSoundAny("weapons/party_horn_01.wav");
}
/*
public Action yz(int client, int args)
{
	if(client == yazi)
	{
		PrintToChat(client, "yazısın");
	}
	if(client == tura)
	{
		PrintToChat(client, "turasin");
	}
	PrintToChat(client, "YAZI: %i   TURA: %i", yazi, tura);
}
*/
public Action LOTTO(int client, int args)
{
	if(!lotoacik)
	{
		buildCreditsMenu(client);
	}
	else CPrintToChat(client, "{darkred}[TurkModders] {green}Şuan zaten bir {orange}yazı-tura {green}oynanıyor.");
	return Plugin_Handled;
}

public void buildCreditsMenu(int client)
{
	int clientCredits = Store_GetClientCredits(client);
	
	Handle menu = CreateMenu(creditsMenu_Callback);
	SetMenuTitle(menu, "%i kredi", creditsToGamble[client]);
	if(!playerIsReady[client])
	{
	if(creditsToGamble[client] <= 0 || creditsToGamble[client] > clientCredits)
		AddMenuItem(menu, "arg7", "Hazır [ ]");
	else if (!playerIsReady[client])
		AddMenuItem(menu, "arg7", "Hazır [ ]");
	else
		AddMenuItem(menu, "arg7", "Hazır [X]");
		
	if (clientCredits > creditsToGamble[client] && clientCredits > 100)
		AddMenuItem(menu, "arg1", "+ 100 kredi");
	else
		AddMenuItem(menu, "arg1", "+ 100 kredi", ITEMDRAW_DISABLED);

	if (clientCredits > creditsToGamble[client] && clientCredits > 200)
		AddMenuItem(menu, "arg2", "+ 200 kredi");
	else
		AddMenuItem(menu, "arg2", "+ 200 kredi", ITEMDRAW_DISABLED);
		
	if (clientCredits > creditsToGamble[client] && clientCredits > 300)
		AddMenuItem(menu, "arg3", "+ 300 kredi");
	else
		AddMenuItem(menu, "arg3", "+ 300 kredi", ITEMDRAW_DISABLED);
		
	if (clientCredits > creditsToGamble[client] && clientCredits > 400)
		AddMenuItem(menu, "arg4", "+ 400 kredi");
	else
		AddMenuItem(menu, "arg4", "+ 400 kredi", ITEMDRAW_DISABLED);
		
	if (clientCredits > creditsToGamble[client] && clientCredits > 500)
		AddMenuItem(menu, "arg5", "+ 500 kredi");
	else
		AddMenuItem(menu, "arg5", "+ 500 kredi", ITEMDRAW_DISABLED);
		
	if (clientCredits > creditsToGamble[client] && clientCredits > 1000)
		AddMenuItem(menu, "arg6", "+ 1000 kredi");
	else
		AddMenuItem(menu, "arg6", "+ 1000 kredi", ITEMDRAW_DISABLED);
	}

	AddMenuItem(menu, "arg8", "Ayrıl");
	SetMenuExitButton(menu, false);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return;
}

public Action buildCreditMenu(Handle timer, int client)
{
	if(playerIsReady[client])
		buildCreditsMenu(client);
	
	return Plugin_Continue;
}

public int creditsMenu_Callback(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char item[60];
		GetMenuItem(menu, param2, item, 60);
		if (StrEqual(item, "arg1"))
		{
			creditsToGamble[client] += 100;
			buildCreditsMenu(client);
		}
		else if (StrEqual(item, "arg2"))
		{
			creditsToGamble[client] += 200;
			buildCreditsMenu(client);
		}
		else if (StrEqual(item, "arg3"))
		{
			creditsToGamble[client] += 300;
			buildCreditsMenu(client);
		}
		else if (StrEqual(item, "arg4"))
		{
			creditsToGamble[client] += 400;
			buildCreditsMenu(client);
		}
		else if (StrEqual(item, "arg5"))
		{
			creditsToGamble[client] += 500;
			buildCreditsMenu(client);
		}
		else if (StrEqual(item, "arg6"))
		{
			creditsToGamble[client] += 1000;
			buildCreditsMenu(client);
		}
		else if (StrEqual(item, "arg7"))
		{
			if (!playerIsReady[client])
			{
				playerIsReady[client] = true;
				CloseHandle(menu);
			}
			else
				playerIsReady[client] = false;
			
			if (playerIsReady[client])
			{
				int clientCredits = Store_GetClientCredits(client);
				if (clientCredits < creditsToGamble[client])
				{
						CPrintToChat(client, "{darkred}[TurkModders] {orange}Bu miktarı girebilmek için {green}yeterli krediniz {lightred}yok.");
						creditsToGamble[client] = 0;
						lotoacik = false;
						playerIsReady[client] = false;
						return;
				}
				if(creditsToGamble[client] == 0)
				{
						CPrintToChat(client, "{darkred}[TurkModders] {orange}Bu miktarı girebilmek için {green}menüden kredi seçmelisiniz.");
						creditsToGamble[client] = 0;
						lotoacik = false;
						playerIsReady[client] = false;
						return;					
				}
				int clientCreditss = Store_GetClientCredits(client);
				Store_SetClientCredits(client, clientCreditss -= creditsToGamble[client]);
				buildHeadsOrTails(client);
				return;
			}
		}
		else if (StrEqual(item, "arg8"))
		{
			char name[60];
			GetClientName(client, name, 60);
			CPrintToChat(client, "{darkred}[TurkModders] {orchid}Yazı tura oyunundan {lightred}ayrıldın.");
			creditsToGamble[client] = 0;
			lotoacik = false;
			playerIsReady[client] = false;
			CloseHandle(menu);
			return;
		}

	}
}

public void buildHeadsOrTails(int client)
{
	Handle menu = CreateMenu(headsTails_callback);
	SetMenuTitle(menu, "Yazı mı Tura mı?");
	AddMenuItem(menu, "heads", "Yazı");
	AddMenuItem(menu, "tails", "Tura");
	SetMenuExitButton(menu, false);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int headsTails_callback(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char item[60];
		GetMenuItem(menu, param2, item, 60);
		if (StrEqual(item, "heads"))
		{
			CPrintToChat(client, "{darkred}[TurkModders] {green}Seçim sonucu: {orchid}Yazı");
			yazi = client;
		} 
		else if (StrEqual(item, "tails"))
		{
			CPrintToChat(client, "{darkred}[TurkModders] {green}Seçim sonucu: {orchid}Tura");
			tura = client;
		}
		//Random heads or tails when start
		lotoacik = true;
		CreateTimer(0.5, make1, client, TIMER_REPEAT);
		rastgele = GetRandomInt(1, 100);
	}
}

public Action make1(Handle timer, any client)
{
	char cliname[64];
	GetClientName(client, cliname, 64);
	static int numPrinted = 0;
	new timeleft = 20 - numPrinted;
	if (numPrinted >= 20) 
	{
		
		if(rastgele > 50)
		{			
				if(client == yazi)
				{ //// BURASI YAZI /////
					int clientCredits = Store_GetClientCredits(client);
					int odul = creditsToGamble[client] *= 2;
					Store_SetClientCredits(client, clientCredits += odul);
					CreateParticle(client, "weapon_confetti_balloons", 5.0);
					PrintHintText(client, "<font color='#00ff2b'>Kazandınız!</font> \n<font color='#00f9ff'>Kazanan Taraf:</font> <font color='#ff00f4'>Yazı</font>\n <font color='#00f9ff'>Kazandığınız Miktar:</font> <font color='#ff0000'>%i</font>", odul);
					CPrintToChatAll("{darkred}[TurkModders] {orange}%s {orchid}yazı-turayı {green}kazandı. {default}({darkblue}Kazanan taraf: Yazı {default}- {darkblue}Kazandığı miktar: %i{default})", cliname, odul);
				}	
				else if(client == tura)
				{
					PrintHintText(client, "<font color='#ff0000'>Kaybettiniz!</font> \n<font color='#00f9ff'>Kazanan Taraf:</font> <font color='#ff00f4'>Yazı</font>\n <font color='#00f9ff'>Kaybettiğiniz Miktar:</font> <font color='#ff0000'>%i</font>", creditsToGamble[client]);
					CPrintToChatAll("{darkred}[TurkModders] {orange}%s {orchid}yazı-turayı {lightred}kaybetti. {default}({darkblue}Kazanan taraf: Yazı {default}- {darkblue}Kaybettiği miktar: %i{default})", cliname, creditsToGamble[client]);
				}
		}
		else
		{	//// BURASI TURA /////				
				if(client == tura)
				{
					int clientCredits = Store_GetClientCredits(client);
					int odul = creditsToGamble[client] *= 2;
					Store_SetClientCredits(client, clientCredits += odul);
					CreateParticle(client, "weapon_confetti_balloons", 5.0);
					PrintHintText(client, "<font color='#00ff2b'>Kazandınız!</font> \n<font color='#00f9ff'>Kazanan Taraf:</font> <font color='#ff00f4'>Tura</font>\n <font color='#00f9ff'>Kazandığınız Miktar:</font> <font color='#ff0000'>%i</font>", odul);
					CPrintToChatAll("{darkred}[TurkModders] {orange}%s {orchid}yazı-turayı {green}kazandı. {default}({darkblue}Kazanan taraf: Tura {default}- {darkblue}Kazandığı miktar: %i{default})", cliname, odul);
				}	
				else if(client == yazi)
				{
					PrintHintText(client, "<font color='#ff0000'>Kaybettiniz!</font> \n<font color='#00f9ff'>Kazanan Taraf:</font> <font color='#ff00f4'>Tura</font>\n <font color='#00f9ff'>Kaybettiğiniz Miktar:</font> <font color='#ff0000'>%i</font>", creditsToGamble[client]);
					CPrintToChatAll("{darkred}[TurkModders] {orange}%s {orchid}yazı-turayı {lightred}kaybetti. {default}({darkblue}Kazanan taraf: Tura {default}- {darkblue}Kaybettiği miktar: %i{default})", cliname, creditsToGamble[client]);
				}
		}
		resle(client);
		numPrinted = 0;
		return Plugin_Stop;
	}
	int random1 = GetRandomInt(1, 2);
	if(random1 == 1)
	{
		PrintHintText(client, "<font color='#ff0000'>Yazı-Tura Atılıyor:</font> \n<font color='#ff00e7'>Yazı</font> <b><font color='#00ff51'>◄◄</font></b> \n<font color='#00f9ff'>Tura</font>");
	}
	if(random1 == 2)
	{
		PrintHintText(client, "<font color='#ff0000'>Yazı-Tura Atılıyor:</font> \n<font color='#ff00e7'>Yazı</font> \n<font color='#00f9ff'>Tura</font> <b><font color='#00ff51'>◄◄</font></b>");
	}
	numPrinted++;		
	return Plugin_Continue;
}

public void resle(int client)
{
	creditsToGamble[client] = 0;
	playerIsReady[client] = false;
	lotoacik = false;
	yazi = 0;
	tura = 0;
} 

//Reset Client Lotto Numbers For New Lotto Use!

stock bool IsValidClient(int client)
{
	return (1 <= client <= MaxClients && IsClientInGame(client));
}

stock CreateParticle(ent, String:particleType[], Float:time)
{
    new particle = CreateEntityByName("info_particle_system");

	decl String:name[64];

    if (IsValidEdict(particle))
    {
        new Float:position[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", position);
        TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
        GetEntPropString(ent, Prop_Data, "m_iName", name, sizeof(name));
        DispatchKeyValue(particle, "targetname", "tf2particle");
        DispatchKeyValue(particle, "parentname", name);
        DispatchKeyValue(particle, "effect_name", particleType);
        DispatchSpawn(particle);
        SetVariantString(name);
        AcceptEntityInput(particle, "SetParent", particle, particle, 0);
        ActivateEntity(particle);
        AcceptEntityInput(particle, "start");
        CreateTimer(time, DeleteParticle, particle);
    }
    EmitSoundToAllAny("weapons/party_horn_01.wav");  
}

public Action:DeleteParticle(Handle:timer, any:particle)
{
    if (IsValidEntity(particle))
    {
        new String:classN[64];
        GetEdictClassname(particle, classN, sizeof(classN));
        if (StrEqual(classN, "info_particle_system", false))
        {
            RemoveEdict(particle);
        }
    }
}