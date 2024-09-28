extends Control

const level = "res://src/world/world.tscn"
const store = "res://src/store/store.tscn"

@onready var animation = $Load/AnimationPlayer
@onready var sprite = $Load/AnimatedSprite2D

const appKeypairPath = "res://resources/accounts/app_keypair.json"
const stakerKeypairPath = "res://resources/accounts/staker-keypair.json"
const rewardMintKeypairPath = "res://resources/accounts/reward-mint-keypair.json"
const stakeMintKeypairPath = "res://resources/accounts/stake-mint-keypair.json"
const token_mint = "HGWZi2ShwhfssETabvomniSKLUZh3BRDYFJBtnhneX5y"

func _ready():
	if !SolanaService.wallet.is_logged_in():
		SolanaService.wallet.connect("on_login_finish", load_game)
	else:
		load_game(true)
	$AudioStreamPlayer.play()

func load_game(success:bool) -> void:
	$GridContainerAfterConnected.visible = false
	$GridContainerBeforeConnected.visible = true
	load_ata()

func _on_quit_texture_button_pressed():
	if OS.get_name() == "HTML5":
		print("Quit not supported in HTML5. Please reload the browser tab.")
	else:
		get_tree().quit()

func _on_play_texture_button_pressed():
	$GridContainerBeforeConnected/QuitTextureButton.visible = false
	$GridContainerBeforeConnected/PlayTextureButton.visible = false
	$GridContainerBeforeConnected/StoreTextureButton.visible = false
	sprite.visible = true
	animation.play("Load")
	await animation.animation_finished
	var _level = get_tree().change_scene_to_file(level)
	animation.stop()
	
func _on_store_texture_button_pressed():
	get_tree().change_scene_to_file(store)
	
func _on_connect_wallet_texture_button_pressed() -> void:
	SolanaService.wallet.try_login()
	
func load_ata() -> void:
	var user_keypair:Keypair = SolanaService.wallet.keypair;
	print(await SolanaService.get_balance(user_keypair.get_public_string()))
	#var reward_mint_keypair:Keypair = Keypair.new_from_file(rewardMintKeypairPath) as Keypair;
	#var app_keypair:Keypair = Keypair.new_from_file(appKeypairPath) as Keypair;
	var staker_keypair:Keypair = Keypair.new_from_file(stakerKeypairPath) as Keypair;
	#var stake_mint_keypair:Keypair = Keypair.new_from_file(stakeMintKeypairPath) as Keypair;
	var token_min_pubkey:Pubkey = Pubkey.new_from_string(token_mint) as Pubkey
	
	var user_ata = await SolanaService.get_associated_token_account(user_keypair.get_public_string(), token_min_pubkey.to_string())
	var staker_ata = await SolanaService.get_associated_token_account(staker_keypair.get_public_string(), token_min_pubkey.to_string())
	var instructions:Array[Instruction];
	#var ata_init_ix: Instruction;
	#print(ata_init_ix)
	#var ata_init_ix = AssociatedTokenAccountProgram.create_associated_token_account(
		#user_keypair,
		#user_ata,
		#token_min_pubkey,
		#SolanaService.token_pid
	#)
	
	var transfer_ix:Instruction = TokenProgram.mint_to(token_min_pubkey.to_string(), staker_ata.to_string(), user_keypair.get_public_string(), staker_keypair.get_public_string(), 2)
	#instructions.append(ata_init_ix);
	instructions.append(transfer_ix);
	#try:
	SolanaService.transaction_manager.sign_transaction(instructions, SolanaService.transaction_manager.Commitment.CONFIRMED, 0, staker_keypair)
		#print("Transaction signed successfully.")
	#except err:
		#print("Error signing transaction: ", err)
	#var transaction:Transaction = Transaction.new()	
	#transaction.add_instruction(transfer_ix)
	#transaction.set_signers([staker_keypair])
	#transaction.set_payer(user_keypair)
	#transaction.sign()
	
	#var tx_data:TransactionData = await SolanaService.transaction_manager.send_transaction(transaction,SolanaService.transaction_manager.Commitment.CONFIRMED)
	
	#print(tx_data)
	#SolanaService.transaction_manager.transfer_token(token_min_pubkey.to_string(), user_ata, 10)
	#print(staker_keypair.get_public_string())
	#print(getAddressBySeed("pool", stake_mint_keypair.to_pubkey()));
	
#func getAddressBySeed(seed:String, publicKey:Pubkey) -> Pubkey:
	#var program_id = SolanaService.token_pid
	#var seed_bytes = seed.to_utf8_buffer()
	#var pubkeyBytes = publicKey.to_bytes()
	#var seeds = [seed_bytes, pubkeyBytes]
	#return SolanaService.get_associated_token_account()
	
	
#func load_keypair(json_path: String) -> Keypair:
	#var file = FileAccess.open(json_path, FileAccess.READ)
	#if file:
		#var json_data = file.get_as_text()
		##var json = JSON.new()
		##var parsed_json = json.parse(json_data)
		#print(json_data)
#
		##if parsed_json.error != OK:
			##print("Error parsing JSON: ", parsed_json.error_string)
			##return null
		#
		##var keypair_data = parsed_json.result
		## Assuming the JSON file contains the keypair data in an array format
		## Create the keypair from the parsed JSON data
		#return SolanaService.wallet.custom_wallet_path()
	#else:
		#print("File not found: ", json_path)
		#return null
	#
