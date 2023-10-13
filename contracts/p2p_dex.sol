// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


contract EscrowFactory {
    address public lawyer;

    event EscrowCreated(
        address indexed buyer,
        address indexed seller,
        address escrow
    );

    event TokensReleased(
        address indexed buyer,
        address indexed seller,
        address escrow
    );

    struct Escrow {
        address buyer;
        address seller;
        address token1;
        address token2;
        uint256 pricePerToken2;
        uint256 amount1;
        uint256 amount2;
    }

    Escrow[] public escrows;
    mapping(address => uint256[]) public userEscrows;
    mapping(address => mapping(address => uint256[])) public tokenEscrows;

    constructor() {
        lawyer = msg.sender;
    }

    function createEscrow(
        address _seller,
        address _token1,
        address _token2,
        uint256 _pricePerToken2,
        uint256 _amount2
    ) public returns (address) {
        require(_seller != address(0), "Invalid seller address");
        require(_token1 != address(0), "Invalid token1 address");
        require(_token2 != address(0), "Invalid token2 address");
        require(_amount2 > 0, "Invalid token2 amount");
        require(_pricePerToken2 > 0, "Invalid price per token2");

        IERC20 token2 = IERC20(_token2);

        require(
            token2.allowance(_seller, address(this)) >= _amount2,
            "Insufficient token2 allowance"
        );

        token2.transferFrom(_seller, address(this), _amount2);

        Escrow memory escrow = Escrow({
            buyer: address(0),
            seller: _seller,
            token1: _token1,
            token2: _token2,
            amount1: _amount2 * _pricePerToken2,
            amount2: _amount2,
            pricePerToken2: _pricePerToken2
        });
        escrows.push(escrow);
        uint256 escrowId = escrows.length - 1;
        tokenEscrows[_token2][_seller].push(escrowId);

        emit EscrowCreated(address(0), _seller, address(this));

        return address(this);
    }

    function buyTokens(
        uint256 _escrowId,
        address _buyer,
        uint256 _amount1
    ) public {
        Escrow storage escrow = escrows[_escrowId];
        require(escrow.buyer == address(0), "Escrow already has a buyer");
        require(escrow.seller != address(0), "Invalid seller address");
        require(_buyer != address(0), "Invalid buyer address");
        require(escrow.token1 != address(0), "Invalid token1 address");
        require(escrow.token2 != address(0), "Invalid token2 address");
        require(_amount1 > 0, "Invalid token1 amount");
        require(
            escrow.amount1 == _amount1,
            "Token1 amount does not match escrow amount"
        );

        IERC20 token1 = IERC20(escrow.token1);

        require(
            token1.allowance(_buyer, address(this)) >= _amount1,
            "Insufficient token1 allowance"
        );


        token1.transferFrom(_buyer, address(this), _amount1);

        escrow.buyer = _buyer;

        userEscrows[_buyer].push(_escrowId);
        emit EscrowCreated(_buyer, escrow.seller, address(this));

        releaseTokens(_escrowId);
    }

    function releaseTokens(uint256 _escrowId) private {
        Escrow storage escrow = escrows[_escrowId];
        require(escrow.buyer != address(0), "Escrow has no buyer");
        require(escrow.amount1 > 0, "Invalid token1 amount");

        IERC20 token1 = IERC20(escrow.token1);
        IERC20 token2 = IERC20(escrow.token2);

        uint256 sellerAmount1 = escrow.amount1;
        uint256 buyerAmount2 = escrow.amount2;

        token1.transfer(escrow.seller, sellerAmount1);
        token2.transfer(escrow.buyer, buyerAmount2);

        emit TokensReleased(escrow.buyer, escrow.seller, address(this));
        delete escrows[_escrowId];
    }

    function getEscrowsForUser(
        address user
    ) public view returns (uint256[] memory) {
        return userEscrows[user];
    }
}
