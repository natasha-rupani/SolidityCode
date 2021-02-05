pragma solidity ^0.5.2;

contract ERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

contract SocialHeroToken is ERC721 {
    string private _name;
    string private _symbol;
    SocialHero[] public socialHeros;
    uint256 private pendingSocislHeroCount;
    mapping (uint256 => address) private _tokenOwner;
    mapping (address => uint256) private _ownedTokensCount;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    mapping(uint256 => SocialHeroTxn[]) private socialHerosTxns;
  //uint256 public index;
    struct SocialHero {
        uint id;
        string name;
        string image;
        string socialImpactSector;
        uint socialImpactFactor;
        uint twitterFollowers;
        string dob;
        uint price;
        uint status;
        address payable owner;
    }
    struct SocialHeroTxn {
       uint256 id; 
       uint256 price;
       address seller;
       address buyer;
       uint txnDate;
       uint status;
    }

   event LogSHEROSold(uint _tokenId, string _name, uint256 _price,  address _current_owner, address _buyer);
   event LogSHEROTokenCreate(uint _tokenId, string _name, string _socialImpactSector, uint256 _price, address _current_owner);
   event LogSHEROResell(uint _tokenId, uint _status, uint256 _price); 
   constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
    }
    function name() external view returns (string memory) {
        return _name;
    }
    function symbol() external view returns (string memory) {
        return _symbol;
    }
    function createTokenAndSellSHERO(string memory _heroName, string memory _socialImpactSector, uint _socialImpactFactor, uint _twitterFollowers,
                                   string memory _dob, uint256 _price, string memory _image) public {
        require(bytes(_heroName).length > 0, 'The Hero name cannot be empty');
        require(bytes(_socialImpactSector).length > 0, 'The social Impact Sector for the SocialHero cannot be empty');
        require(_socialImpactFactor > 0, 'The social Impact Factor for the SocialHero cannot be empty');
        require(_twitterFollowers > 0, 'Twitter followers for the SocialHero cannot be empty');
        require(bytes(_dob).length > 0, 'The date of birth for the SocialHero cannot be empty');
        require(_price > 0, 'The price cannot be empty');
        require(bytes(_image).length > 0, 'The image cannot be empty');
        SocialHero memory _socialHero = SocialHero({
          id: _twitterFollowers+_socialImpactFactor,
          name: _heroName,
          image: _image,
          socialImpactSector: _socialImpactSector,
          socialImpactFactor: _socialImpactFactor,
          twitterFollowers: _twitterFollowers,
          dob: _dob,
          price: _price,
          status: 1,
          owner: msg.sender
        });
        uint256 tokenId = socialHeros.push(_socialHero) - 1;
        _mint(msg.sender, tokenId); 
        emit LogSHEROTokenCreate(tokenId, _name, _socialImpactSector, _price, msg.sender);
        pendingSocislHeroCount++;
    }

    function buySHERO(uint256 _tokenId) payable public {
        (uint256 _id, string memory _heroName, string memory _image, string memory _socialImpactSector, uint256 _socialImpactFactor, uint256 _twitterFollowes, string memory _dob, uint256 _price, uint _status,address payable _current_owner ) =  findSHERO(_tokenId);
        require(_current_owner != address(0));
        require(msg.sender != address(0));
        require(msg.sender != _current_owner);
        require(msg.value >= _price);
        require(socialHeros[_tokenId].owner != address(0));

        //transfer ownership of art
        _transfer(_current_owner, msg.sender, _tokenId);
        //return extra payment
        if(msg.value > _price) msg.sender.transfer(msg.value - _price);
        //make a payment
        _current_owner.transfer(_price);
        socialHeros[_tokenId].owner = msg.sender;
        socialHeros[_tokenId].status = 0;
        SocialHeroTxn memory _socialHeroTxn = SocialHeroTxn({
            id: _id,
            price: _price,
            seller: _current_owner,
            buyer: msg.sender,
            txnDate: now,
            status: _status
        });
        socialHerosTxns[_id].push(_socialHeroTxn);
        pendingSocislHeroCount--;
        
        emit LogSHEROSold(_id, _heroName, _price, _current_owner, msg.sender);
    }
    function resellSHERO(uint256 _tokenId, uint256 _price) payable public {
          require(msg.sender != address(0));
          require(isOwnerOf(_tokenId,msg.sender));
          socialHeros[_tokenId].status = 1;
          socialHeros[_tokenId].price = _price;
          pendingSocislHeroCount++;
          emit LogSHEROResell(_tokenId, 1, _price);  
    }
    function findSHERO(uint256 _tokenId) public view   returns (
        uint256, string memory, string memory, string memory, uint256, uint256 , string memory, uint256, uint,address payable){
            SocialHero memory socialHero = socialHeros[_tokenId];
            return (socialHero.id, socialHero.name, socialHero.image, socialHero.socialImpactSector, socialHero.socialImpactFactor, socialHero.twitterFollowers, socialHero.dob, socialHero.price, socialHero.status, socialHero.owner);
    }
  
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        _ownedTokensCount[_to]++;
        _ownedTokensCount[_from]--;
        _tokenOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }
    function _mint(address _to, uint256 tokenId) internal {
        require(_to != address(0));
        require(!_exists(tokenId));
        _tokenOwner[tokenId] = _to;
        _ownedTokensCount[_to]++;
        emit Transfer(address(0), _to, tokenId);
    }
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

   function balanceOf(address _owner) public view returns (uint256) {
        return _ownedTokensCount[_owner];
    }
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        require(_exists(_tokenId),"ERC721: nonexistant token");
        _owner = _tokenOwner[_tokenId];
    }
    function approve(address _to, uint256 _tokenId) public {
        _tokenApprovals[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        require(_to != address(0));
        require(isOwnerOf(_tokenId, _from));
        _transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public {
        require(_to != address(0));
        require(isOwnerOf(_tokenId, msg.sender));
        _transfer(msg.sender, _to, _tokenId);
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
       // transferFrom(_from,  _to,  _tokenId);
    }
    function getApproved(uint256 tokenId) public view returns (address operator) {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool _approved) public {
        require(operator != msg.sender);
        _operatorApprovals[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    
    function isOwnerOf(uint256 tokenId, address account) public view returns (bool) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner == account;
    }
    function isApproved(address _to, uint256 _tokenId) private view returns (bool) {
        return _tokenApprovals[_tokenId] == _to;
    }
    function isContract(address _account) internal view returns (bool) {
        uint256 _size;
        assembly { _size := extcodesize(_account)}
        return _size > 0;
    }
     function _checkOnERC721Received(address _from, address _to, uint256 _tokenId, bytes memory _data) view private returns (bool) {
        if (!isContract(_to)) {
            return true;
        }
     }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public {
        transferFrom(_from,  _to,  _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data));
        }
}